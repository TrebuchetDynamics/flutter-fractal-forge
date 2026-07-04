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

const int MAX_ITERS = 120;

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

float hash11(float p) {
  return fract(sin(p * 127.1) * 43758.5453123);
}

vec2 cyclosorusStep(vec2 z, float r) {
  if (r < 0.02) {
    return vec2(0.0, 0.20 * z.y);
  } else if (r < 0.84) {
    return vec2(0.85 * z.x + 0.04 * z.y, -0.04 * z.x + 0.86 * z.y + 1.55);
  } else if (r < 0.93) {
    return vec2(0.22 * z.x - 0.26 * z.y, 0.23 * z.x + 0.22 * z.y + 1.55);
  }
  return vec2(-0.17 * z.x + 0.28 * z.y, 0.26 * z.x + 0.24 * z.y + 0.44);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  // map to fern coordinates
  vec2 query = vec2(p.x * 3.0, (p.y + 0.2) * 5.0);

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  // ponytail: stochastic fern density converges enough for thumbnails well below 500 samples.
  int steps = int(clamp(float(target), 24.0, 120.0));
  float bailout = max(4.0, uBailout);

  vec2 z = vec2(0.0);
  float density = 0.0;
  float trapSq = 1e9;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= steps) break;

    float r = hash11(float(i) + floor(uTime * 0.05));
    z = cyclosorusStep(z, r);

    if (dot(z, z) > bailout * bailout * 4.0) {
      z *= 0.5;
    }

    vec2 dz = z - query;
    float d2 = dot(dz, dz);
    trapSq = min(trapSq, d2);
    density += 1.0 / (1.0 + 35.0 * d2);
  }

  float edge = exp(-9.0 * sqrt(trapSq));
  float signal = density / float(steps) * 3.0 + edge;

  if (signal < 0.05) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(0.2 * signal + 0.15 * edge + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= smoothstep(0.04, 0.8, signal);

  fragColor = vec4(linearToSRGB(color), 1.0);
}
