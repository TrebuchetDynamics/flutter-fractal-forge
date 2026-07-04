#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

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

float sdArc(vec2 p, vec2 c, float r) {
  return abs(length(p - c) - r);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p = vec2(p.x * 2.2 + 0.5, p.y * 2.2 + 0.03);

  int target = int(clamp(uIterations, 24.0, float(MAX_ITERS)));
  int qMax = int(clamp(6.0 + float(target) * 0.08, 6.0, 24.0));

  float best = 1e9;
  float bestQ = 1.0;

  // ponytail: Ford-circle Farey proxy; the exact adjacent-fraction search was cubic per pixel.
  for (int q = 1; q <= 24; q++) {
    if (q > qMax) break;
    for (int n = 0; n <= 24; n++) {
      if (n > q) break;
      float fq = float(q);
      float x = float(n) / fq;
      float r = 0.42 / (fq * fq);
      float d = sdArc(p, vec2(x, r), r);
      if (d < best) {
        best = d;
        bestQ = fq;
      }
    }
  }

  float line = exp(-170.0 * best);
  float band = exp(-35.0 * abs(p.y));
  line = max(line, band * step(p.y, 0.0) * 0.5);

  if (line < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float qNorm = clamp(log(bestQ + 1.0) / log(float(qMax) + 1.0), 0.0, 1.0);
  float t = fract(qNorm + 0.05 * uTime * 0.01 + 0.2 * line);
  vec3 col = getPaletteColor(t, int(uColorScheme));
  col *= mix(0.2, 1.2, line);

  fragColor = vec4(linearToSRGB(col), (uTransparentBg > 0.5) ? line : 1.0);
}
