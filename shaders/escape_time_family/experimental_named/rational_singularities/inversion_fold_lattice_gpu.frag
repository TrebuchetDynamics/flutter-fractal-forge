#include <flutter/runtime_effect.glsl>

precision highp float;

// Inversion Fold Lattice — clean-room, single-pass escape-time shader.
//
// The map is the inversion fold
//     p <- |p| / |p|^2 - c
// with a small rotation applied after each fold, and orbit accumulation used
// for colour. Unlike every other escape-time entry in this catalog the orbit is
// driven by the reciprocal of the radius rather than by a polynomial power, so
// the filigree structure is a lattice of fold intersections rather than bulbs.
//
// The classic Mandelbrot analogue of the same map keeps c = pixel. This entry
// ships the Julia side (c fixed) because it is zoom-stable: panning and zooming
// keep revealing new fold detail instead of leaving the interesting band.

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uJuliaReal;
uniform float uJuliaImag;
uniform float uFoldRotation;
uniform float uTrapWeight;

out vec4 fragColor;

const int MAX_ITERS = 128;

// IEC 61966-2-1 sRGB transfer function (linear -> display-encoded).
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

// Cohesive ink -> deep blue -> violet -> magenta -> gold -> warm white ramp.
// Scheme 0 uses it directly so the field keeps a dark background and luminous
// crests instead of the flat mid-tones a bare cosine palette produces.
vec3 inkRamp(float t) {
  t = clamp(t, 0.0, 1.0);
  vec3 c = mix(vec3(0.010, 0.014, 0.030), vec3(0.055, 0.115, 0.300), smoothstep(0.00, 0.16, t));
  c = mix(c, vec3(0.230, 0.150, 0.470), smoothstep(0.16, 0.36, t));
  c = mix(c, vec3(0.760, 0.250, 0.440), smoothstep(0.36, 0.56, t));
  c = mix(c, vec3(0.980, 0.640, 0.260), smoothstep(0.56, 0.78, t));
  c = mix(c, vec3(1.000, 0.960, 0.840), smoothstep(0.78, 1.00, t));
  return c;
}

vec3 schemeColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return inkRamp(t);
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.45), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return mix(inkRamp(t), clamp(iqPalette(t, a, b, c, d), 0.0, 1.0), 0.55);
}

mat2 rot(float a) {
  float c = cos(a), s = sin(a);
  return mat2(c, -s, s, c);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  // Same framing convention as the other escape-time shaders: the shorter
  // screen axis spans roughly +-1 at uZoom = 1.
  vec2 p = uv * 2.0 / max(0.000001, uZoom) + uCenter;

  vec2 c = vec2(uJuliaReal, uJuliaImag);
  int target = int(clamp(uIterations, 4.0, float(MAX_ITERS)));
  // Slow fold breathing keeps the entry animatable without touching the orbit
  // statistics that the colour mapping depends on.
  mat2 fold = rot(uFoldRotation + 0.06 * sin(uTime * 0.00025));
  float limit = max(2.0, uBailout);
  float limit2 = limit * limit;

  float trap = 1e9;
  float energy = 0.0;
  float blowup = 0.0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    float d2 = dot(p, p);
    if (d2 > limit2 || d2 < 1e-9) {
      // The reciprocal map is unbounded; stop before inf/nan leaks into colour.
      blowup = (d2 > limit2) ? 1.0 : 0.0;
      break;
    }

    p = abs(p) / max(d2, 1e-6) - c;
    p = fold * p;

    float trace = abs(p.x) + abs(p.y);
    trap = min(trap, trace);
    energy += exp(-5.0 * trace);
  }

  // The map is largely convergent, so there is no escape time to colour by.
  // The orbit trace carries the structure instead: `energy` accumulates how
  // close the orbit stays to the trap, and log(1+energy)/log(1+target) maps it
  // into 0..1 using a fixed divisor, so no per-image normalisation is needed.
  float density = log(1.0 + max(energy, 0.0)) / log(1.0 + float(target));
  float ridge = 1.0 / (1.0 + 60.0 * trap);
  float shade = 0.55 * pow(density, 1.4) + 0.45 * ridge * (0.35 + 0.65 * density);
  shade = clamp(1.45 * shade - 0.12, 0.0, 1.0);
  shade *= mix(1.0, 0.45, blowup);
  shade *= mix(0.55, 1.0, clamp(uTrapWeight, 0.0, 1.0));

  vec3 color = schemeColor(shade, int(uColorScheme));
  color *= 0.25 + 0.95 * shade;

  if (shade < 0.02 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
