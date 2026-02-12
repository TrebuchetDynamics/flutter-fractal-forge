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
  p = fract(p * vec2(173.31, 417.93));
  p += dot(p, p + 29.17);
  return fract(p.x * p.y);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float occProb = clamp(0.45 + 0.08 * sin(0.01 * float(target)), 0.2, 0.8);

  vec2 c = floor(p * 110.0);
  float occupied = step(hash21(c), occProb);

  float connected = 0.0;
  vec2 walker = vec2(0.0);
  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    vec2 sampleCell = c + walker;
    float occ = step(hash21(sampleCell), occProb);
    if (occ > 0.5 && length(sampleCell) < 2.0) {
      connected = 1.0;
    }

    float h = hash21(sampleCell + vec2(float(i), -float(i)));
    if (h < 0.25) walker += vec2(1.0, 0.0);
    else if (h < 0.50) walker += vec2(-1.0, 0.0);
    else if (h < 0.75) walker += vec2(0.0, 1.0);
    else walker += vec2(0.0, -1.0);

    walker = clamp(walker, vec2(-8.0), vec2(8.0));
  }

  float cluster = occupied * connected;
  float t = fract(0.6 * cluster + 0.25 * occupied + uTime * 0.0001 + 0.01 * length(c));

  vec3 openCol = vec3(0.02, 0.02, 0.03);
  vec3 occCol = getPaletteColor(0.2 + t, int(uColorScheme)) * 0.6;
  vec3 cluCol = getPaletteColor(0.75 + t, int(uColorScheme));
  vec3 color = mix(openCol, occCol, occupied);
  color = mix(color, cluCol, cluster);

  if (occupied < 0.5 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(color, 1.0);
}
