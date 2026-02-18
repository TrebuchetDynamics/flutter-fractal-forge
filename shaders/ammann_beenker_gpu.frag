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

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 p = (fc - 0.5 * uResolution) / max(1.0, scale);
  p = p / max(0.000001, uZoom) + uCenter;
  p *= 4.0;

  int nProj = int(clamp(4.0 + uIterations * 0.03, 4.0, 16.0));
  float best = 1e9;
  float phase = 0.0;
  float phi = 2.41421356237;

  for (int k = 0; k < 16; k++) {
    if (k >= nProj) break;
    float a = 3.14159265 * float(k) / 8.0;
    vec2 dir = vec2(cos(a), sin(a));
    float x = dot(p, dir);

    float stripe = abs(fract(x * phi + 0.5 * sin(float(k) + uTime * 0.00003)) - 0.5);
    best = min(best, stripe);
    phase += stripe * exp(-0.12 * float(k));
  }

  float lines = exp(-95.0 * best);
  float bg = exp(-0.35 * dot(p, p));
  float vis = max(lines, 0.15 * bg);

  if (vis < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float t = fract(phase * 1.7 + 0.2 * lines + uTime * 0.0001);
  vec3 col = getPaletteColor(t, int(uColorScheme));
  col *= mix(0.25, 1.2, vis);
  fragColor = vec4(linearToSRGB(col), (uTransparentBg > 0.5) ? vis : 1.0);
}
