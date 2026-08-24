#include <flutter/runtime_effect.glsl>

precision highp float;

// Minkowski question-mark function ?(x) and the Stern-Brocot / Farey tree.
// ?(x) is a strictly increasing singular function mapping rationals to
// dyadic rationals; its graph is a fractal staircase dense in jumps.
//
// We evaluate ?(x) for x in (0,1) through its continued fraction
// x = [0; a1, a2, ...]: the binary expansion of ?(x) has runs whose lengths
// are the a_k, toggling between 0 and 1 bits.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (used as max continued-fraction depth)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uMode;          // 10 (0=graph,1=derivative heatmap,2=Stern-Brocot tree)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 paletteFor(float t, float s) {
  int scheme = int(clamp(floor(s + 0.5), 0.0, 63.0));
  if (scheme == 0) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.4)), 0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  if (scheme == 1) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)), 0.5 + 0.5 * cos(6.28318 * (t + 0.3)), 0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  if (scheme == 2) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.33)), 0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float sf = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * sf + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * sf + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * sf + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (sf + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

// ?(x) for x in [0,1], via continued fraction -> binary digit runs.
float qmark(float x0) {
  float x = clamp(x0, 1e-9, 1.0 - 1e-9);
  float value = 0.0;
  float place = 0.5;
  float parity = 1.0; // first integer part of reciprocal is a1 (fractional run)
  for (int i = 0; i < 32; i++) {
    float r = 1.0 / x;         // reciprocal
    float a = floor(r);        // integer part (next continued-fraction term)
    x = r - a;                 // remainder
    // Append 'a' bits of current parity. (Constant loop bound for GPUs;
    // the run length is handled by an early break on the dynamic value.)
    float abits = min(a, 30.0);
    for (int j = 0; j < 30; j++) {
      if (float(j) >= abits) break;
      if (parity > 0.5) value += place;
      place *= 0.5;
      if (place < 1e-9) break;
    }
    parity = 1.0 - parity;
    if (x < 1e-7) break;
  }
  return value;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 2.0));
  // x in [0,1], y in [0,1] — our own little window (offset by uCenter/zoom).
  vec2 p = uv + vec2(0.5 + uCenter.x, 0.5 + uCenter.y);
  p = clamp(p, 0.0, 1.0);
  float x = p.x;
  float y = p.y;

  vec3 color;
  if (mode == 0) {
    // Graph of ?(x): brighten a thin band around y = ?(x).
    float qv = qmark(x);
    float band = 1.0 - smoothstep(0.0, 0.02, abs(y - qv));
    // The graph is a monotone singular staircase: emphasize jump columns and
    // the horizontal extents.
    float q2 = qmark(clamp(x + 0.002, 0.0, 1.0));
    float slope = clamp(abs(q2 - qv) * 400.0, 0.0, 1.0);
    vec3 base = paletteFor(fract(qv * 5.0), uColorScheme);
    color = mix(base * 0.3, vec3(1.0), band) + base * slope * 0.5;
  } else if (mode == 1) {
    // Derivative heatmap: ?'(x)=0 a.e. but dense blow-ups -> striated texture.
    float qv = qmark(x);
    float qL = qmark(clamp(x - 0.003, 0.0, 1.0));
    float qR = qmark(clamp(x + 0.003, 0.0, 1.0));
    float d = abs(qR - qL) * 300.0;
    float t = fract(d * 0.8 + qv);
    color = paletteFor(t, uColorScheme) * clamp(d, 0.0, 1.0) +
            vec3(0.05);
  } else {
    // Stern-Brocot / Farey tree: vertical strokes at rationals p/q.
    // Draw a stroke at x=p/q with strength 1/q (classic Farey shading).
    float sum = 0.0;
    for (int q = 1; q <= 40; q++) {
      for (int p = 0; p <= 40; p++) {
        if (p > q) break; // constant bounds only; skip improper fractions
        float fx = float(p) / float(q);
        float d = abs(x - fx);
        float w = 1.0 / float(q * q);
        sum += smoothstep(0.002, 0.0, d) * w;
      }
    }
    float fv = qmark(x);
    color = mix(vec3(0.06), paletteFor(fract(fv * 7.0), uColorScheme), sum);
  }

  float alpha = uTransparentBg > 0.5 ? 1.0 : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
