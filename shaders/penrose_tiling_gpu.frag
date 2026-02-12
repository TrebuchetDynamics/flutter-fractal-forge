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
const float PI = 3.14159265359;
const float PHI = 1.61803398875;

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
  p *= 5.0;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = clamp(target / 24 + 2, 2, 18);

  // de Bruijn dual style: project on 5 star directions and classify by 36°/72° edge relation.
  float minGap = 1e9;
  float secondGap = 1e9;
  float a0 = 1e9;
  float a1 = 1e9;

  for (int i = 0; i < 5; i++) {
    float ang = 2.0 * PI * float(i) / 5.0;
    vec2 dir = vec2(cos(ang), sin(ang));
    float t = dot(p, dir) * PHI;
    float f = abs(fract(t) - 0.5);
    if (f < minGap) {
      secondGap = minGap;
      minGap = f;
      a1 = a0;
      a0 = ang;
    } else if (f < secondGap) {
      secondGap = f;
      a1 = ang;
    }
  }

  float da = abs(a0 - a1);
  da = min(da, 2.0 * PI - da);

  float thinWeight = smoothstep(PI / 5.0 - 0.05, PI / 5.0 + 0.05, da);
  float thickWeight = 1.0 - thinWeight;

  float edge = exp(-28.0 * minGap * float(depth) / 6.0);
  if (edge < 0.08) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec3 thinColor = getPaletteColor(0.22 + 0.6 * fract(minGap * 6.0 + uTime * 0.00008), int(uColorScheme));
  vec3 thickColor = getPaletteColor(0.72 + 0.6 * fract(secondGap * 7.0 + uTime * 0.00008), int(uColorScheme));
  vec3 color = mix(thickColor, thinColor, thinWeight);
  color *= 0.35 + 0.95 * edge;
  color *= mix(0.9, 1.15, thickWeight);

  fragColor = vec4(color, 1.0);
}
