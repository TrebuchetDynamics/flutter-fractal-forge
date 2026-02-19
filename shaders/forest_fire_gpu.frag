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
  p = fract(p * vec2(234.34, 435.345));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));

  vec2 cell = floor(p * 96.0);
  float tree = step(0.38, hash21(cell));
  float burning = 0.0;

  float lightning = 0.004 + 0.01 / max(1.0, uBailout);
  float growth = 0.03;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;
    float fi = float(i);

    float n1 = step(0.82, hash21(cell + vec2(1.0, 0.0) + fi));
    float n2 = step(0.82, hash21(cell + vec2(-1.0, 0.0) - fi));
    float n3 = step(0.82, hash21(cell + vec2(0.0, 1.0) + 2.0 * fi));
    float n4 = step(0.82, hash21(cell + vec2(0.0, -1.0) - 2.0 * fi));
    float fireNeighbor = max(max(n1, n2), max(n3, n4));

    float ignite = step(1.0 - lightning, hash21(cell + vec2(fi, -fi)));
    burning = max(burning * 0.45, tree * max(fireNeighbor, ignite));

    float regrow = step(1.0 - growth, hash21(cell + vec2(-fi, fi)));
    tree = max(tree * (1.0 - burning), regrow * (1.0 - burning));
  }

  float state = burning > 0.25 ? 2.0 : (tree > 0.4 ? 1.0 : 0.0);
  vec3 color;
  if (state < 0.5) {
    color = vec3(0.03, 0.02, 0.02);
  } else if (state < 1.5) {
    color = mix(vec3(0.05, 0.2, 0.08), getPaletteColor(0.3 + 0.2 * tree, int(uColorScheme)), 0.55);
  } else {
    color = mix(vec3(0.95, 0.35, 0.08), getPaletteColor(0.05 + 0.7 * burning, int(uColorScheme)), 0.35);
  }

  if (state < 0.5 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
