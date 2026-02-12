#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = vec2(0.0);

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailoutSq = max(0.5, uBailout) * max(0.5, uBailout);

  int it = target;
  float interiorOrbit = 0.0;
  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

    // Interior-orbit density surrogate (normalized orbital energy)
    float radius2 = dot(z, z);
    interiorOrbit += exp(-2.2 * radius2);

    if (radius2 > bailoutSq) {
      it = i;
      break;
    }
  }

  // Anti-Buddhabrot approximation: emphasize points that do NOT escape.
  if (it < target) {
    if (uTransparentBg > 0.5) {
      fragColor = vec4(0.0);
      return;
    }
    vec3 bg = vec3(0.01, 0.01, 0.02);
    fragColor = vec4(bg, 1.0);
    return;
  }

  float density = interiorOrbit / max(1.0, float(target));
  float invDensity = 1.0 - clamp(density, 0.0, 1.0); // inverted density
  float t = fract(0.75 * invDensity + 0.25 * density + 0.03 * uTime);

  vec3 base = getPaletteColor(t, int(uColorScheme));
  vec3 color = mix(base * 1.2, vec3(1.0), smoothstep(0.55, 1.0, invDensity));
  color *= 0.35 + 1.15 * pow(invDensity, 0.9);
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
