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

mat2 rot45() {
  return mat2(0.70710678, -0.70710678, 0.70710678, 0.70710678);
}

float levyOrbitDensity(vec2 p, int depth) {
  vec2 q = p;
  float density = 0.0;
  float trap = 1e9;
  mat2 r = rot45();

  for (int i = 0; i < 64; i++) {
    if (i >= depth) break;

    if (q.x + q.y > 0.0) {
      q = r * q - vec2(0.8, 0.0);
    } else {
      q = transpose(r) * q + vec2(0.8, 0.0);
    }

    q *= 1.41421356;
    float d = abs(q.y) / pow(1.41421356, float(i + 1));
    trap = min(trap, d);
    density += exp(-55.0 * d);
  }

  return density * 0.18 + exp(-38.0 * trap);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p *= 2.8;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = int(clamp(float(target / 8 + 2), 2.0, 64.0));
  float bailout = max(2.0, uBailout);

  float d0 = levyOrbitDensity(p, depth);
  float d1 = levyOrbitDensity(p + vec2(0.45, -0.12), depth);
  float d2 = levyOrbitDensity(p + vec2(-0.35, 0.26), depth);
  float d3 = levyOrbitDensity(vec2(-p.y, p.x) * 0.93, depth);

  float density = (d0 + d1 + d2 + d3) * 0.25;
  density = min(density, bailout * 1.2);

  if (density < 0.045) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(0.16 * density + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= smoothstep(0.04, 0.9, density);

  fragColor = vec4(linearToSRGB(color), 1.0);
}
