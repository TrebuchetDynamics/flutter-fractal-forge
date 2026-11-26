#include <flutter/runtime_effect.glsl>

precision highp float;

// Double-float (DS) precision Mandelbrot shader.
//
// Keep the pixel offset in the low part of c and carry it through the
// recurrence. The uniform layout matches MandelbrotDf2UniformSlots.
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

// Keep the standard path's analytic interior shortcut. Test membership in
// double-float too; float32 rounding near an edge could hide escaping pixels.
bool inMainBulb(vec2 cx, vec2 cy) {
  vec2 y2 = dsMul(cy, cy);
  vec2 x = dsSub(cx, vec2(0.25, 0.0));
  vec2 q = dsAdd(dsMul(x, x), y2);
  if (dsSub(dsMul(q, dsAdd(q, x)), 0.25 * y2).x < 0.0) return true;
  x = dsAdd(cx, vec2(1.0, 0.0));
  return dsSub(dsAdd(dsMul(x, x), y2), vec2(0.0625, 0.0)).x < 0.0;
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

  // Between the new and original DF2 entry points only precision changes:
  // keep the standard shader's coloring, including its relief palettes.
  bool standardColoring = uZoom < 5e6;
  if (standardColoring && inMainBulb(cx, cy)) {
    fragColor = vec4(0.0, 0.0, 0.0, uTransparentBg > 0.5 ? 0.0 : 1.0);
    return;
  }
  int scheme = int(uColorScheme);
  bool relief = standardColoring && scheme >= 50;
  vec2 der = vec2(0.0);
  vec2 zx = vec2(0.0);
  vec2 zy = vec2(0.0);
  float bailoutSq = uBailout * uBailout;
  float mag2 = 0.0;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    if (relief) {
      // dz/dc is needed only for lighting; it never feeds back into z.
      der = 2.0 * vec2(zx.x * der.x - zy.x * der.y,
                       zx.x * der.y + zy.x * der.x) + vec2(1.0, 0.0);
    }
    vec2 zx2 = dsMul(zx, zx);
    vec2 zy2 = dsMul(zy, zy);
    zy = dsAdd(2.0 * dsMul(zx, zy), cy);
    zx = dsAdd(dsSub(zx2, zy2), cx);
    // Float32 is sufficient for the post-update escape test and shading,
    // but never feed the rounded values back into the recurrence.
    mag2 = zx.x * zx.x + zy.x * zy.x;
    if (mag2 > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  float contour = 0.0;
  if (!standardColoring) {
    float cx_f = cx.x + cx.y;
    float cy_f = cy.x + cy.y;
    contour = 0.18 * sin(12.0 * cx_f + 7.0 * cy_f) +
        0.12 * cos(23.0 * length(vec2(cx_f, cy_f)));
  }

  if (it >= target) {
    if (uTransparentBg > 0.5) {
      fragColor = vec4(0.0);
    } else if (standardColoring) {
      fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
      vec3 interior = palette(fract(contour + uTime * 0.0001), scheme) * 0.72;
      fragColor = vec4(linearToSRGB(interior), 1.0);
    }
    return;
  }

  float smoothVal = float(it) - log2(log2(max(1e-12, mag2))) + 4.0;
  float t = fract(smoothVal / 64.0);
  if (relief) {
    // Match mandel_step_smooth.frag's normal estimate and light-angle mapping.
    float angle = float(scheme - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2(zx.x * der.x + zy.x * der.y,
                   zy.x * der.x - zx.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;
    float light = pow(clamp((dot(nv, lightDir) + 0.5) / 1.5, 0.0, 1.0),
                      1.0 / 1.8);
    int reliefIndex = scheme - 50;
    int basePalette = reliefIndex - (reliefIndex / 4) * 4;
    vec3 col = palette(fract(smoothVal / 64.0 + uTime * 0.0001),
                       basePalette) * light;
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }
  vec3 col = palette(fract(t + contour + uTime * 0.0001), scheme);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
