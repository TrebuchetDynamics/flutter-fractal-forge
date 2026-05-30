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
  p = fract(p * vec2(234.34, 851.73));
  p += dot(p, p + 23.17);
  return fract(p.x * p.y);
}

int seededState(ivec2 c) {
  // 0 empty, 1 electron head, 2 electron tail, 3 conductor
  float h = hash21(vec2(c));
  float line = abs(fract(float(c.x) * 0.17 + float(c.y) * 0.11) - 0.5);
  bool conductor = (h > 0.38) || (line < 0.08);
  if (!conductor) return 0;
  if (h > 0.94) return 1;
  if (h > 0.88) return 2;
  return 3;
}

int evolveCell(ivec2 c, int steps) {
  int state = seededState(c);

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= steps) break;

    if (state == 1) {
      state = 2;
    } else if (state == 2) {
      state = 3;
    } else if (state == 3) {
      int heads = 0;
      for (int oy = -1; oy <= 1; oy++) {
        for (int ox = -1; ox <= 1; ox++) {
          if (ox == 0 && oy == 0) continue;
          int n = seededState(c + ivec2(ox, oy));
          if (n == 1) heads++;
        }
      }
      if (heads == 1 || heads == 2) state = 1;
      else state = 3;
    }
  }

  return state;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int steps = clamp(target / 6, 1, 80);
  ivec2 cell = ivec2(floor(p * 96.0));

  int state = evolveCell(cell, steps);

  float glow = 0.0;
  for (int oy = -1; oy <= 1; oy++) {
    for (int ox = -1; ox <= 1; ox++) {
      int s = evolveCell(cell + ivec2(ox, oy), steps);
      if (s == 1) glow += 0.3;
      if (s == 2) glow += 0.15;
    }
  }

  vec3 color;
  if (state == 0) {
    color = vec3(0.02, 0.02, 0.03);
  } else if (state == 1) {
    color = getPaletteColor(0.15 + 0.2 * glow + uTime * 0.0002, int(uColorScheme));
  } else if (state == 2) {
    color = vec3(0.95, 0.35, 0.12);
  } else {
    color = vec3(0.85, 0.72, 0.18) * (0.75 + 0.25 * smoothstep(0.0, 1.0, glow));
  }

  if (state == 0 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
