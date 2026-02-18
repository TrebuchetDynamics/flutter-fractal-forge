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
vec3 getPaletteColor(float t, int s) {
  t = fract(t);
  if (s == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (s == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.00, 0.15, 0.20));
  if (s == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));
  float fs = float(s);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37 * fs + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29 * fs + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11 * fs + 0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (fs + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

mat2 rot(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }

float pentFold(inout vec2 p) {
  const float PI5 = 0.62831853072;
  float sector = floor(atan(p.y, p.x) / PI5 + 0.5);
  p *= rot(-sector * PI5);
  p.x = abs(p.x);
  return abs(sector);
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 p = (fc - 0.5 * uResolution) / max(1.0, scale);
  p = p / max(0.000001, uZoom) + uCenter;
  p *= 2.4;

  int depth = int(clamp(3.0 + 0.07 * uIterations, 3.0, 28.0));
  float best = 1e9;
  float acc = 0.0;
  vec2 z = p;

  for (int i = 0; i < 28; i++) {
    if (i >= depth) break;
    acc += pentFold(z);
    z = z * 1.65 - vec2(0.78, 0.0);
    float edge = abs(length(z) - 1.0) / exp2(float(i) * 0.65);
    best = min(best, edge);
  }

  float line = exp(-170.0 * best);
  if (line < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float t = fract(0.08 * acc + 0.2 * line + uTime * 0.0001);
  vec3 col = getPaletteColor(t, int(uColorScheme));
  col *= mix(0.2, 1.15, line);
  fragColor = vec4(linearToSRGB(col), (uTransparentBg > 0.5) ? line : 1.0);
}
