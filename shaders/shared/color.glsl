// ── Canonical shared color utilities ─────────────────────────────────────
// Include in fractal shaders to get linearToSRGB, palette, getPaletteColor,
// and the low-level iqPalette builder. Covers all 452 palette-using shaders.
//
// Functions provided:
//   linearToSRGB(lin)            — IEC 61966-2-1 sRGB transfer function.
//   iqPalette(t, a, b, c, d)    — low-level cosine palette builder.
//   palette(t, scheme)           — cosine-inline variant (288 shaders).
//   getPaletteColor(t, scheme)   — IQ-wrapper, standard procedural (147 shaders).
//   getPaletteColorAlt(t, scheme)— IQ-wrapper, alternate procedural (17 shaders).
//
// The two getPaletteColor variants share identical schemes 0-3. Only the
// procedural (scheme ≥ 4) formula differs. Call sites choose the variant.

// ── sRGB ──────────────────────────────────────────────────────────────────
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// ── Low-level IQ cosine palette ───────────────────────────────────────────
vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

// ── palette() — cosine-inline variant (288 shaders) ──────────────────────
// Schemes 0-3 use hand-tuned phase offsets. Schemes ≥4 use standard
// procedural ABCD with a=sin, b=cos, c=sin, d=fract(sin) generators.
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

// ── getPaletteColor() — IQ-wrapper, standard procedural (147 shaders) ────
// Schemes 0-3 use iqPalette with hand-tuned ABCD.
// Schemes ≥4 use the same procedural formula as palette().
vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

// ── getPaletteColorAlt() — IQ-wrapper, alternate procedural (17 shaders) ─
// Schemes 0-3 identical to getPaletteColor. Schemes ≥4 use alternate noise
// generators (different amplitude/frequency/phase than the standard).
vec3 getPaletteColorAlt(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.10, 0.20));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }

  float s = float(scheme);
  vec3 a = vec3(0.5 + 0.2 * sin(vec3(s * 1.1, s * 1.3, s * 1.7)));
  vec3 b = vec3(0.5 + 0.3 * cos(vec3(s * 0.7, s * 1.1, s * 0.3)));
  vec3 c = vec3(1.0 + sin(vec3(s * 0.5, s * 0.9, s * 1.3)));
  vec3 d = vec3(fract(s * 0.13), fract(s * 0.17), fract(s * 0.23));
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}