#include <flutter/runtime_effect.glsl>

precision highp float;

// Halley z⁴−1: Halley's method for z⁴−1=0, four roots ±1, ±i.
// Halley's method achieves cubic convergence for smooth f: for f(z)=z⁴−1,
// the step simplifies to Δz = 2z(z⁴−1)/(5z⁴+3).
// Roots: 1 (angle 0), i (π/2), −1 (π), −i (−π/2).
// Color: HSV where hue encodes the nearest root phase, value encodes
// iteration count. The four basins of attraction produce quaternary symmetry
// with fractal boundary (the Julia set of Halley's map on z⁴−1).
// Supports color scheme offset via uColorScheme.
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 hsv2rgb(float h, float s, float v) {
  vec3 c = clamp(abs(fract(h + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
  return v * mix(vec3(1.0), c, s);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }

vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b, b);
  return vec2(dot(a, b), a.y*b.x - a.x*b.y) / max(d, 1e-20);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  float rootAngle = 0.0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    vec2 z2  = cmul(z, z);
    vec2 z4  = cmul(z2, z2);
    vec2 z4m1 = z4 - vec2(1.0, 0.0);
    // Halley step: Δz = 2z(z⁴−1)/(5z⁴+3)
    vec2 num  = 2.0 * cmul(z, z4m1);
    vec2 denom = 5.0 * z4 + vec2(3.0, 0.0);
    vec2 step_v = cdiv(num, denom);
    z = z - step_v;
    if (dot(step_v, step_v) < 1e-12) { it = j; rootAngle = atan(z.y, z.x); break; }
    if (dot(z, z) > max(uBailout*uBailout, 64.0)) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  // Map the 4 root angles (0, π/2, π, ±3π/2) to distinct hues
  float hue = fract(rootAngle * (1.0 / 6.28318) + 0.5 + float(schemeInt) * (1.0 / 8.0));
  float bright = pow(1.0 - float(it) / float(target), 0.45);
  fragColor = vec4(linearToSRGB(hsv2rgb(hue, 0.88, bright)), 1.0);
}
