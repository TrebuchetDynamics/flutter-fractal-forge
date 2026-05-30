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

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b * cos(6.28318 * (c * t + d)); }
vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

float spectreCell(vec2 p) {
  const mat2 R = mat2(0.62349, -0.781831, 0.781831, 0.62349);
  vec2 q = p;
  float edge = 1e9;
  for (int i = 0; i < 7; i++) {
    q = vec2(abs(q.x), q.y);
    if (q.x + 0.72 * q.y > 1.0) q = vec2(1.0, 0.0) - q;
    edge = min(edge, abs(q.x + 0.72 * q.y - 1.0));
    q = R * (q * 1.68 - vec2(0.57, 0.22));
  }
  float core = max(abs(q.x) - 0.40, abs(q.y) - 0.31);
  return min(edge, core);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));

  vec2 q = p;
  float acc = 0.0;
  float hit = 1e9;
  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;
    float d = spectreCell(q);
    hit = min(hit, abs(d));
    acc += exp(-42.0 * abs(d));
    q = vec2(q.x - 0.42 * q.y, 0.28 * q.x + q.y) * 1.05 + vec2(-0.19, 0.27);
  }

  float mask = smoothstep(0.03, 0.0, hit);
  float t = fract(0.34 * log(1.0 + acc) + 0.23 * mask + uTime * 0.00003);
  vec3 col = getPaletteColor(t, int(uColorScheme));
  col = mix(col * 0.30, col, mask);
  fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? mix(0.2, 0.95, mask) : 1.0);
}
