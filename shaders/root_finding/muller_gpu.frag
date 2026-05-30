#include <flutter/runtime_effect.glsl>

precision highp float;

// Muller's method on z^3 - 1.
// Three-point parabolic interpolation.
// Track z_{n-2}, z_{n-1}, z_n; fit quadratic through (z_{n-2},f_{n-2}), (z_{n-1},f_{n-1}), (z_n,f_n).
// z_{n+1} = z_n - 2*f_n / (b +/- sqrt(b^2 - 4*a*f_n))
// where a, b are divided difference coefficients.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.4)),0.5+0.5*cos(6.28318*(t+0.7)));
  } else if (scheme == 1) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.5)),0.5+0.5*cos(6.28318*(t+0.3)),0.5+0.5*cos(6.28318*(t+0.0)));
  } else if (scheme == 2) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.33)),0.5+0.5*cos(6.28318*(t+0.67)));
  } else if (scheme == 3) {
    float g = 0.5+0.5*cos(6.28318*t); return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37*s+0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29*s+0.2));
  vec3 c_v = 1.0 + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c_v*t+d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b, b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}

vec2 csqrt(vec2 z) {
  float r = length(z);
  float a = atan(z.y, z.x) * 0.5;
  float sr = sqrt(r);
  return vec2(sr * cos(a), sr * sin(a));
}

vec2 f_z3m1(vec2 z) {
  vec2 z2 = cmul(z, z);
  return cmul(z2, z) - vec2(1.0, 0.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z0_init = uv / max(0.000001, uZoom) + uCenter;

  // Initialize three starting points near z0
  vec2 z_2 = z0_init + vec2(0.01, 0.0);
  vec2 z_1 = z0_init - vec2(0.01, 0.0);
  vec2 z_0 = z0_init;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 f0 = f_z3m1(z_0);
    vec2 f1 = f_z3m1(z_1);
    vec2 f2 = f_z3m1(z_2);

    vec2 h0 = z_0 - z_1;
    vec2 h1 = z_1 - z_2;

    // Divided differences
    vec2 d01 = cdiv(f0 - f1, h0);
    vec2 d12 = cdiv(f1 - f2, h1);
    vec2 dd = cdiv(d01 - d12, h0 + h1);

    // Quadratic coefficients relative to z_0
    vec2 bv = d01 + cmul(h0, dd);
    vec2 av = dd;

    // Discriminant: b^2 - 4*a*f0
    vec2 disc = cmul(bv, bv) - 4.0 * cmul(av, f0);
    vec2 sqrtDisc = csqrt(disc);

    // Choose sign for larger denominator
    vec2 dPlus  = bv + sqrtDisc;
    vec2 dMinus = bv - sqrtDisc;
    vec2 denom = (dot(dPlus, dPlus) > dot(dMinus, dMinus)) ? dPlus : dMinus;

    vec2 step = cdiv(2.0 * f0, denom);

    // Shift history
    z_2 = z_1;
    z_1 = z_0;
    z_0 = z_0 - step;

    if (dot(step, step) < 1e-12) { it = j; break; }
    if (dot(z_0, z_0) > 64.0) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec2 r0 = vec2(1.0, 0.0);
  vec2 r1 = vec2(-0.5, 0.86602540378);
  vec2 r2 = vec2(-0.5, -0.86602540378);

  float d0 = dot(z_0 - r0, z_0 - r0);
  float d1 = dot(z_0 - r1, z_0 - r1);
  float d2 = dot(z_0 - r2, z_0 - r2);

  float rootPhase = 0.0;
  if (d1 < d0 && d1 < d2) rootPhase = 0.3333333;
  else if (d2 < d0 && d2 < d1) rootPhase = 0.6666667;

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime * 0.0001);
  vec3 color = palette(t, int(uColorScheme));
  fragColor = vec4(linearToSRGB(color), 1.0);
}
