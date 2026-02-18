#version 460 core
// Lyapunov Fractal — Standard sequence "AB"
// Maps (a, b) parameters to complex plane coords.
// Computes Lyapunov exponent λ for logistic map x = r*x*(1-x)
// where r alternates between a and b per the sequence.
// λ > 0 = chaos (warm colors), λ < 0 = stability (cool colors).

precision highp float;

#include <flutter/runtime_effect.glsl>

// Standard 10-uniform layout
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;    // unused but kept for layout compat
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

// ── IQ palette ──────────────────────────────────
vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.0,0.33,0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.0,0.10,0.20));
  if (scheme == 2) return iqPalette(t, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,0.7,0.4), vec3(0.0,0.15,0.20));
  if (scheme == 3) return iqPalette(t, vec3(0.5,0.5,0.5), vec3(0.5,0.5,0.5), vec3(1.0,1.0,1.0), vec3(0.0,0.0,0.0));
  // Procedural for 4-63
  float s = float(scheme);
  vec3 a = vec3(0.5 + 0.2*sin(s*1.1), 0.5 + 0.2*sin(s*1.3), 0.5 + 0.2*sin(s*1.7));
  vec3 b = vec3(0.5 + 0.3*cos(s*0.7), 0.5 + 0.3*cos(s*1.1), 0.5 + 0.3*cos(s*0.3));
  vec3 c = vec3(1.0 + sin(s*0.5), 1.0 + sin(s*0.9), 1.0 + sin(s*1.3));
  vec3 d = vec3(fract(s*0.13), fract(s*0.17), fract(s*0.23));
  return iqPalette(t, a, b, c, d);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float aspect = uResolution.x / uResolution.y;
  vec2 uv = (fragCoord - 0.5 * uResolution) / min(uResolution.x, uResolution.y);

  // Map to parameter space: a = x-axis (2..4), b = y-axis (2..4)
  float a = uCenter.x + uv.x / uZoom;
  float b = uCenter.y + uv.y / uZoom;

  int iters = int(uIterations);
  if (iters > MAX_ITERS) iters = MAX_ITERS;

  // Warmup: run a few iterations to settle
  float x = 0.5;
  int warmup = 50;
  for (int i = 0; i < 50; i++) {
    if (i >= warmup) break;
    // Sequence "AB": even=a, odd=b
    float r = (i & 1) == 0 ? a : b;
    x = r * x * (1.0 - x);
    x = clamp(x, 1e-10, 1.0 - 1e-10);
  }

  // Compute Lyapunov exponent
  float lyapunov = 0.0;
  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= iters) break;
    float r = (i & 1) == 0 ? a : b;
    x = r * x * (1.0 - x);
    x = clamp(x, 1e-10, 1.0 - 1e-10);
    float deriv = abs(r * (1.0 - 2.0 * x));
    if (deriv > 1e-10) {
      lyapunov += log(deriv);
    }
  }
  lyapunov /= float(iters);

  int cs = int(uColorScheme);

  // Color: negative = stable (blue tones), positive = chaotic (warm tones)
  vec3 color;
  if (lyapunov < 0.0) {
    // Stable: map [-3, 0] to palette with cool bias
    float t = clamp(-lyapunov / 3.0, 0.0, 1.0);
    color = getPaletteColor(t * 0.5, cs); // lower half of palette
  } else {
    // Chaotic: map [0, 2] to palette warm range
    float t = clamp(lyapunov / 2.0, 0.0, 1.0);
    color = getPaletteColor(0.5 + t * 0.5, cs); // upper half
  }

  float alpha = 1.0;
  if (uTransparentBg > 0.5 && lyapunov < -2.5) {
    alpha = 0.0;
  }

  fragColor = vec4(linearToSRGB(color), alpha);
}
