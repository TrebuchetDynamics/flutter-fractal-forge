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
  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p *= 2.8;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = clamp(target / 18 + 4, 4, 40);

  // Rauzy-like membership via tribonacci substitution contraction maps.
  vec2 q = p;
  float trap = 1e9;
  float code = 0.0;

  for (int i = 0; i < 40; i++) {
    if (i >= depth) break;

    if (q.x >= q.y && q.x >= 0.0) {
      q = vec2(0.62 * q.x - 0.28 * q.y - 0.18, 0.38 * q.x + 0.72 * q.y - 0.06);
      code += 1.0;
    } else if (q.y >= q.x && q.y >= 0.0) {
      q = vec2(0.68 * q.x + 0.22 * q.y + 0.14, -0.34 * q.x + 0.58 * q.y - 0.09);
      code += 2.0;
    } else {
      q = vec2(0.54 * q.x - 0.46 * q.y + 0.03, 0.41 * q.x + 0.49 * q.y + 0.21);
      code += 3.0;
    }

    trap = min(trap, length(q));
  }

  float member = smoothstep(0.85, 0.05, trap);
  if (member < 0.05) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(0.07 * code / float(depth) + 0.8 * member + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.45 + 0.85 * member;

  fragColor = vec4(color, 1.0);
}
