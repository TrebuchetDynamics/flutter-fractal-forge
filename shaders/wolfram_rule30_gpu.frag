#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

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

float rule30(float l, float c, float r) {
  // 111 110 101 100 011 010 001 000 -> 0 0 0 1 1 1 1 0
  float idx = 4.0 * l + 2.0 * c + r;
  return (idx > 0.5 && idx < 4.5) ? 1.0 : 0.0;
}

float cellStateRule30(int gen, int cell) {
  float v = (cell == 0) ? 1.0 : 0.0;
  for (int g = 0; g < MAX_ITERS; g++) {
    if (g >= gen) break;
    float left = 0.0;
    float center = v;
    float right = 0.0;

    if (cell > -MAX_ITERS) {
      int cL = cell - 1;
      int cR = cell + 1;

      float vL = (cL == 0) ? 1.0 : 0.0;
      float vC = (cell == 0) ? 1.0 : 0.0;
      float vR = (cR == 0) ? 1.0 : 0.0;

      for (int k = 0; k < MAX_ITERS; k++) {
        if (k >= g) break;
        float nL = rule30(0.0, vL, vC);
        float nC = rule30(vL, vC, vR);
        float nR = rule30(vC, vR, 0.0);
        vL = nL;
        vC = nC;
        vR = nR;
      }
      left = vL;
      center = vC;
      right = vR;
    }

    v = rule30(left, center, right);
  }
  return v;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int gen = int(floor((p.y + 0.5) * float(target)));
  gen = clamp(gen, 0, target - 1);
  int cell = int(floor((p.x + 0.5) * float(target)));

  float alive = cellStateRule30(gen, cell);

  if (alive < 0.5 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float t = fract(float(gen) / max(1.0, float(target)) + float(cell) * 0.001 + uTime * 0.0001);
  vec3 col = mix(vec3(0.02, 0.02, 0.04), getPaletteColor(t, int(uColorScheme)), alive);
  fragColor = vec4(col, 1.0);
}
