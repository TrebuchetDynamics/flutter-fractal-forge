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
uniform float uRule;          // 10

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

float elementaryRule(float rule, float l, float c, float r) {
  float idx = 4.0 * l + 2.0 * c + r;
  float bit = pow(2.0, clamp(floor(idx + 0.5), 0.0, 7.0));
  return step(bit, mod(floor(rule / bit), 2.0) * bit);
}

float bitIsSet(float value, float bit) {
  return mod(floor(value / bit), 2.0);
}

float rule90State(int gen, int cell) {
  float n = float(gen);
  float x = float(cell);
  if (abs(x) > n || mod(n + x, 2.0) > 0.5) return 0.0;

  // Lucas theorem: C(n, k) is odd iff every set bit in k is also set in n.
  float k = floor((n + x) * 0.5);
  float alive = 1.0;
  for (int i = 0; i < 9; i++) {
    float bit = pow(2.0, float(i));
    alive *= 1.0 - bitIsSet(k, bit) * (1.0 - bitIsSet(n, bit));
  }
  return alive;
}

float rule150State(int gen, int cell) {
  if (cell > gen || -cell > gen || int(mod(float(gen + cell), 2.0)) != 0) return 0.0;
  float parity = 0.0;

  // Rule 150 from one seed is the parity of signed subset sums from the
  // set bits of n in (x^-1 + 1 + x)^n. The catalog view is 256 rows, so
  // 8 binary digits cover the issue without SkSL dynamic arrays.
  for (int combo = 0; combo < 6561; combo++) {
    int code = combo;
    int sum = 0;
    for (int bitIndex = 0; bitIndex < 8; bitIndex++) {
      float bit = pow(2.0, float(bitIndex));
      if (bitIsSet(float(gen), bit) > 0.5) {
        int choice = int(mod(float(code), 3.0));
        code = code / 3;
        sum += (choice - 1) * int(bit + 0.5);
      }
    }
    if (sum == cell) parity = 1.0 - parity;
  }
  return parity;
}

float cellStateRule30(int gen, int cell) {
  float rule = clamp(floor(uRule + 0.5), 0.0, 255.0);
  if (abs(rule - 90.0) < 0.5) return rule90State(gen, cell);
  if (abs(rule - 150.0) < 0.5) return rule150State(gen, cell);

  // ponytail: generic elementary CA uses a procedural single-pass texture;
  // exact arbitrary-rule evolution was O(generation^2) per pixel and unusable.
  float n = float(gen);
  float x = float(cell);
  float inCone = 1.0 - step(n + 0.5, abs(x));
  float h = fract(sin(dot(vec2(x, n), vec2(12.9898, 78.233)) + rule * 0.37) * 43758.5453);
  float spine = 1.0 - smoothstep(0.0, max(1.0, n * 0.08), abs(x));
  return max(inCone * step(0.49 + 0.12 * sin(n * 0.11 + rule), h), spine * 0.7);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float row = fract(p.y + 0.5);
  int gen = int(floor(row * float(target)));
  gen = int(clamp(float(gen), 0.0, float(target - 1)));
  float cellCoord = (p.x + 0.5) * float(target);
  int cell = int(floor(cellCoord));
  float cellEdge = max(abs(fract(cellCoord) - 0.5), abs(fract(row * float(target)) - 0.5));
  float pixelDetail = 1.0 - smoothstep(0.42, 0.50, cellEdge);

  float alive = cellStateRule30(gen, cell) * (0.72 + 0.28 * pixelDetail);

  if (alive < 0.5 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float t = fract(float(gen) / max(1.0, float(target)) + float(cell) * 0.001 + 0.06 * pixelDetail + uTime * 0.0001);
  vec3 col = mix(vec3(0.02, 0.02, 0.04), getPaletteColor(t, int(uColorScheme)), alive);
  col += vec3(0.06, 0.07, 0.10) * pixelDetail * step(0.5, alive);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
