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

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

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

float hash21(vec2 p) {
  p = fract(p * vec2(127.1, 311.7));
  p += dot(p, p + 91.7);
  return fract(p.x * p.y);
}

float cellAt(vec2 cell, float stepId) {
  float seed = step(0.74, hash21(cell + vec2(2.3, -4.7)));
  float phase = fract(0.11 * stepId + hash21(cell + vec2(stepId, -stepId)));
  return step(0.5, abs(seed - step(0.58, phase)));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  vec2 cell = floor(p * 100.0);
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float stepId = floor(0.25 * float(target) + uTime * 0.6);

  float alive = cellAt(cell, stepId);

  float n = 0.0;
  for (int oy = -1; oy <= 1; oy++) {
    for (int ox = -1; ox <= 1; ox++) {
      if (ox == 0 && oy == 0) continue;
      n += cellAt(cell + vec2(float(ox), float(oy)), stepId - 1.0);
    }
  }

  // HighLife (requested variant): birth on 2,3,6; survival on 2,3.
  float birth = (abs(n - 2.0) < 0.1 || abs(n - 3.0) < 0.1 || abs(n - 6.0) < 0.1) ? 1.0 : 0.0;
  float survive = (abs(n - 2.0) < 0.1 || abs(n - 3.0) < 0.1) ? 1.0 : 0.0;
  float nextAlive = (alive > 0.5) ? survive : birth;

  vec3 deadCol = vec3(0.02, 0.02, 0.03);
  vec3 liveCol = getPaletteColor(0.2 + 0.13 * n + 0.05 * hash21(cell), int(uColorScheme));
  vec3 col = mix(deadCol, liveCol, nextAlive);

  if (nextAlive < 0.5 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(linearToSRGB(col), 1.0);
}
