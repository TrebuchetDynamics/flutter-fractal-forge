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

float hash21(vec2 p) {
  p = fract(p * vec2(443.8975, 397.2973));
  p += dot(p, p + 19.19);
  return fract(p.x * p.y);
}

float seedOn(vec2 cell) {
  float h = hash21(cell + vec2(11.2, -7.7));
  return step(0.84, h); // sparse "on" seeds
}

float isOnAtStep(vec2 cell, float stepId) {
  // Hash-seeded pseudo-evolution: keeps GPU-safe stateless behavior.
  float s0 = seedOn(cell);
  float h = hash21(cell + vec2(stepId, -stepId * 1.73));
  float burst = step(0.985, h);
  return max(s0 * step(0.5, fract(0.19 * stepId + hash21(cell))), burst);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  vec2 cell = floor(p * 90.0);
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float tStep = floor(0.35 * float(target) + uTime * 0.5);

  float onNow = isOnAtStep(cell, tStep);
  float onPrev = isOnAtStep(cell, tStep - 1.0);

  float neighbors = 0.0;
  for (int oy = -1; oy <= 1; oy++) {
    for (int ox = -1; ox <= 1; ox++) {
      if (ox == 0 && oy == 0) continue;
      neighbors += isOnAtStep(cell + vec2(float(ox), float(oy)), tStep - 1.0);
    }
  }

  // Brian's Brain: off->on with exactly 2 on-neighbors, on->dying, dying->off.
  float wasDying = (onPrev < 0.5 && onNow < 0.5) ? 1.0 - step(0.5, abs(neighbors - 2.0)) : 0.0;
  float born = (onNow < 0.5 && onPrev < 0.5) ? (1.0 - step(0.5, abs(neighbors - 2.0))) : 0.0;
  float state = onNow > 0.5 ? 2.0 : (wasDying > 0.5 ? 1.0 : born > 0.5 ? 2.0 : 0.0);

  vec3 offCol = vec3(0.01, 0.015, 0.03);
  vec3 dyingCol = mix(vec3(0.22, 0.3, 0.55), getPaletteColor(0.55, int(uColorScheme)), 0.35);
  vec3 onCol = mix(vec3(0.6, 0.95, 1.0), getPaletteColor(0.85 + 0.1 * hash21(cell), int(uColorScheme)), 0.45);

  vec3 col = offCol;
  if (state > 1.5) col = onCol;
  else if (state > 0.5) col = dyingCol;

  if (state < 0.5 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(col, 1.0);
}
