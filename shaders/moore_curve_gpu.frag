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

float grayCode(float x) {
  float b0 = mod(floor(x), 2.0);
  float b1 = mod(floor(x * 0.5), 2.0);
  float b2 = mod(floor(x * 0.25), 2.0);
  return b0 + abs(b1 - b0) * 2.0 + abs(b2 - b1) * 4.0;
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 p = (fc - 0.5 * uResolution) / max(1.0, scale);
  p = p / max(0.000001, uZoom) + uCenter;

  int depth = int(clamp(2.0 + 0.08 * uIterations, 2.0, 10.0));
  float n = exp2(float(depth));

  vec2 g = (p * 1.7 + 0.5) * n;
  vec2 cell = floor(g);
  vec2 local = fract(g) - 0.5;

  float gx = grayCode(cell.x);
  float gy = grayCode(cell.y);
  float parity = mod(gx + gy, 2.0);

  float dH = abs(local.y);
  float dV = abs(local.x);
  float d = mix(dH, dV, parity);

  float conn = min(abs(abs(local.x) - 0.5), abs(abs(local.y) - 0.5));
  d = min(d, conn * 0.7);

  float line = exp(-90.0 * d);
  if (line < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float idx = fract((gx + 2.0 * gy) / max(1.0, n * n));
  float t = fract(idx + 0.2 * line + uTime * 0.00008);
  vec3 col = getPaletteColor(t, int(uColorScheme));
  col *= mix(0.2, 1.2, line);

  fragColor = vec4(col, (uTransparentBg > 0.5) ? line : 1.0);
}
