#include <flutter/runtime_effect.glsl>

precision highp float;

// Schröder z⁶−1: Schröder's method for z⁶−1=0, six roots of unity.
// For n=6: step = 2z(z⁶−1)/(7z⁶+5), z → z − step.
// Six roots: e^(2πik/6) for k=0..5 at angles 0°,60°,120°,180°,240°,300°.
// Color: HSV hue encodes root phase, value encodes iteration count.
// Hexagonal symmetry produces six wedge-shaped basins with fractal boundary;
// even degree yields bilateral mirror symmetry across three reflection axes.
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
    vec2 z3  = cmul(z2, z);
    vec2 z6  = cmul(z3, z3);
    vec2 z6m1 = z6 - vec2(1.0, 0.0);
    // Schröder step for n=6: 2z(z⁶−1)/(7z⁶+5)
    vec2 num   = 2.0 * cmul(z, z6m1);
    vec2 denom = 7.0*z6 + vec2(5.0, 0.0);
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

  float hue = fract(rootAngle * (1.0 / 6.28318) + 0.5 + float(schemeInt) * (1.0 / 12.0));
  float bright = pow(1.0 - float(it) / float(target), 0.45);
  fragColor = vec4(linearToSRGB(hsv2rgb(hue, 0.88, bright)), 1.0);
}
