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
uniform float uVariant;
uniform float uCellScale;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  if (s < 1.0) return iqPalette(t, vec3(0.50), vec3(0.50), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s < 2.0) return iqPalette(t, vec3(0.25, 0.35, 0.45), vec3(0.35), vec3(1.0), vec3(0.55, 0.20, 0.05));
  if (s < 3.0) return iqPalette(t, vec3(0.45, 0.25, 0.08), vec3(0.50, 0.35, 0.15), vec3(1.0, 0.8, 0.45), vec3(0.0, 0.12, 0.25));
  if (s < 4.0) return vec3(0.25 + 0.75 * t);
  return iqPalette(t, vec3(0.48), vec3(0.50), vec3(1.0, 0.7, 0.4), vec3(fract(s * 0.17), 0.28, 0.62));
}

float pascalOdd(float n, float k) {
  if (k < 0.0 || k > n) return 0.0;
  float nn = n;
  float kk = k;
  for (int i = 0; i < 18; i++) {
    float nd = mod(nn, 2.0);
    float kd = mod(kk, 2.0);
    if (kd > nd + 0.1) return 0.0;
    nn = floor(nn * 0.5);
    kk = floor(kk * 0.5);
    if (nn < 1.0 && kk < 1.0) break;
  }
  return 1.0;
}

bool isPrime(int n) {
  if (n < 2) return false;
  if (n == 2) return true;
  if ((n / 2) * 2 == n) return false;
  for (int d = 3; d < 128; d += 2) {
    if (d * d > n) break;
    if ((n / d) * d == n) return false;
  }
  return true;
}

int iabs(int v) {
  return v < 0 ? -v : v;
}

int ulamIndex(int x, int y) {
  int ax = iabs(x);
  int ay = iabs(y);
  int layer = ax > ay ? ax : ay;
  int side = 2 * layer;
  if (side < 1) side = 1;
  int maxN = (2 * layer + 1) * (2 * layer + 1);
  if (y == -layer) return maxN - (layer - x);
  if (x == -layer) return maxN - side - (layer + y);
  if (y == layer) return maxN - 2 * side - (layer + x);
  return maxN - 3 * side - (layer - y);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = uResolution.x < uResolution.y ? uResolution.x : uResolution.y;
  scale = scale < 1.0 ? 1.0 : scale;
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = uv / max(uZoom, 0.0001) + uCenter;

  float cellScale = clamp(uCellScale, 20.0, 180.0);
  vec2 grid = floor(p * cellScale);
  vec2 cell = fract(p * cellScale) - 0.5;
  float cellAx = cell.x < 0.0 ? -cell.x : cell.x;
  float cellAy = cell.y < 0.0 ? -cell.y : cell.y;
  float gridLine = smoothstep(0.48, 0.42, cellAx > cellAy ? cellAx : cellAy);

  vec3 color = vec3(0.015, 0.015, 0.025);
  float alpha = 1.0;

  if (uVariant < 0.5) {
    float n = floor((0.95 - p.y) * cellScale * 0.6);
    float k = floor((p.x + 0.5 * n / max(cellScale * 0.6, 1.0)) * cellScale * 0.6);
    float inside = step(0.0, n) * step(0.0, k) * step(k, n);
    float odd = pascalOdd(n, k) * inside;
    float t = fract(n * 0.015 + k * 0.021 + uTime * 0.00004);
    color = mix(color, palette(t, uColorScheme), odd * gridLine);
  } else {
    int x = int(grid.x);
    int y = int(grid.y);
    int n = ulamIndex(x, y);
    float prime = isPrime(n) ? 1.0 : 0.0;
    float axis = max(1.0 - smoothstep(0.0, 1.2, abs(float(x))),
                     1.0 - smoothstep(0.0, 1.2, abs(float(y)))) * 0.18;
    float t = fract(float(n) * 0.0031 + uTime * 0.00003);
    color += axis;
    color = mix(color, palette(t, uColorScheme), prime * gridLine);
  }

  if (length(color) < 0.05 && uTransparentBg > 0.5) alpha = 0.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
