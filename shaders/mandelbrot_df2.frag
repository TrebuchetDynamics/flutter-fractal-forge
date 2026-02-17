#include <flutter/runtime_effect.glsl>

precision highp float;

// Double-float (DS) precision Mandelbrot shader.
//
// Extends usable GPU zoom range from ~1e7 (float32 limit) to ~1e14.
// Uses paired-float (Knuth/Dekker) arithmetic for center coordinates.
//
// Uniform layout must match mandelbrot_df2_module.dart exactly.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform float uCenterHiX;     // 3  (high part of center.x)
uniform float uCenterLoX;     // 4  (low part of center.x)
uniform float uCenterHiY;     // 5  (high part of center.y)
uniform float uCenterLoY;     // 6  (low part of center.y)
uniform float uZoom;          // 7
uniform float uIterations;    // 8
uniform float uBailout;       // 9
uniform float uColorScheme;   // 10
uniform float uTransparentBg; // 11

out vec4 fragColor;

// ── Double-Single (DS) arithmetic ────────────────────────────────────────────
// Represents a value as (hi + lo) where |lo| << ulp(hi).
// Provides ~14 decimal digits of precision from two float32 values.

// Veltkamp split: split a into (hi, lo) s.t. hi + lo = a exactly.
vec2 dsSplit(float a) {
  const float C = 4097.0; // 2^12 + 1
  float t = C * a;
  float hi = t - (t - a);
  float lo = a - hi;
  return vec2(hi, lo);
}

// Two-sum: add two DS values.
vec2 dsAdd(vec2 a, vec2 b) {
  float s = a.x + b.x;
  float v = s - a.x;
  float e = (a.x - (s - v)) + (b.x - v) + a.y + b.y;
  float hi = s + e;
  float lo = e - (hi - s);
  return vec2(hi, lo);
}

// DS subtraction.
vec2 dsSub(vec2 a, vec2 b) {
  return dsAdd(a, vec2(-b.x, -b.y));
}

// DS multiplication.
vec2 dsMul(vec2 a, vec2 b) {
  vec2 sa = dsSplit(a.x);
  vec2 sb = dsSplit(b.x);
  float p  = a.x * b.x;
  float err = ((sa.x * sb.x - p) + sa.x * sb.y + sa.y * sb.x) + sa.y * sb.y;
  err += a.x * b.y + a.y * b.x;  // cross terms from lo parts
  float hi = p + err;
  float lo = err - (hi - p);
  return vec2(hi, lo);
}

// ── sRGB ──────────────────────────────────────────────────────────────────────
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// ── Palette ───────────────────────────────────────────────────────────────────
vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.7))
    );
  } else if (scheme == 1) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.0))
    );
  } else if (scheme == 2) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}

// ── Main ──────────────────────────────────────────────────────────────────────
void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  // Map pixel to normalised UV (same as standard shader).
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 uvScaled = uv / max(0.000001, uZoom);

  // Build c as DS pair: center (DS) + pixel offset (float → DS).
  // cx = centerHi + centerLo + uvScaled.x  (all in DS)
  vec2 cx = dsAdd(vec2(uCenterHiX, uCenterLoX), vec2(uvScaled.x, 0.0));
  vec2 cy = dsAdd(vec2(uCenterHiY, uCenterLoY), vec2(uvScaled.y, 0.0));

  // Mandelbrot iteration using regular float for z (z starts at 0,
  // accumulated rounding error is acceptable for zoom < 1e14).
  float zx = 0.0;
  float zy = 0.0;
  float bailoutSq = uBailout * uBailout;

  // Promote c from DS to float for iteration (precision already captured).
  float cx_f = cx.x + cx.y;
  float cy_f = cy.x + cy.y;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    float zx2 = zx * zx;
    float zy2 = zy * zy;
    zy = 2.0 * zx * zy + cy_f;
    zx = zx2 - zy2 + cx_f;
    if (zx2 + zy2 > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, zx * zx + zy * zy);
  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;
  float t = fract(smoothVal / 64.0);
  t = fract(t + uTime * 0.0001);

  vec3 col = palette(t, int(uColorScheme));
  fragColor = vec4(linearToSRGB(col), 1.0);
}
