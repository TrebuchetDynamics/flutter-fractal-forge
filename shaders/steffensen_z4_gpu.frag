#include <flutter/runtime_effect.glsl>

precision highp float;

// Steffensen's method for z⁴ − 1 = 0  (4th roots of unity: ±1, ±i).
// Simplified Aitken/Steffensen step:
//   w = z + f(z),  z ← z − f(z) / ((w+z)(w²+z²))
// (via w⁴−z⁴ = (w−z)(w+z)(w²+z²), cancelling one factor of f(z)=w−z).
// Four-basin fractal with 4-fold rotational symmetry.  Boundary complexity
// differs from Newton z⁴−1 due to the Aitken acceleration term.
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

vec3 palette(float t, int scheme) {
  if (scheme == 0) return vec3(0.5+0.5*cos(6.28318*(t+0.0)), 0.5+0.5*cos(6.28318*(t+0.4)), 0.5+0.5*cos(6.28318*(t+0.7)));
  if (scheme == 1) return vec3(0.5+0.5*cos(6.28318*(t+0.5)), 0.5+0.5*cos(6.28318*(t+0.3)), 0.5+0.5*cos(6.28318*(t+0.0)));
  if (scheme == 2) return vec3(0.5+0.5*cos(6.28318*(t+0.0)), 0.5+0.5*cos(6.28318*(t+0.33)), 0.5+0.5*cos(6.28318*(t+0.67)));
  if (scheme == 3) { float g = 0.5+0.5*cos(6.28318*t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55+0.15*sin(vec3(1.0,2.0,3.0)*(0.37*s+0.1));
  vec3 b = 0.45+0.25*cos(vec3(1.7,2.3,2.9)*(0.29*s+0.2));
  vec3 c4 = 1.0+0.80*sin(vec3(0.8,1.3,1.7)*(0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719)*(s+0.5))*43758.5453);
  return clamp(a+b*cos(6.28318*(c4*t+d)),0.0,1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b,b);
  if (d < 1e-30) return vec2(1e15, 0.0);
  return vec2(a.x*b.x+a.y*b.y, a.y*b.x-a.x*b.y)/d;
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

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    if (dot(z,z) > max(uBailout*uBailout, 64.0)) { it = j; break; }

    vec2 z2 = cmul(z, z);
    vec2 z4 = cmul(z2, z2);
    vec2 fz = z4 - vec2(1.0, 0.0);             // f(z) = z⁴ − 1

    if (dot(fz, fz) < 1e-14) { it = j; break; }

    // w = z + f(z);  w⁴−z⁴ = (w+z)(w²+z²)·f(z), so denom = (w+z)(w²+z²)
    vec2 w     = z + fz;
    vec2 w2    = cmul(w, w);
    vec2 denom = cmul(w + z, w2 + z2);

    float dd = dot(denom, denom);
    if (dd < 1e-20) { it = j; break; }

    z = z - cdiv(fz, denom);
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  // Four 4th roots of unity: 1, i, −1, −i
  vec2 r0 = vec2( 1.0,  0.0);
  vec2 r1 = vec2( 0.0,  1.0);
  vec2 r2 = vec2(-1.0,  0.0);
  vec2 r3 = vec2( 0.0, -1.0);
  float d0 = dot(z-r0, z-r0);
  float d1 = dot(z-r1, z-r1);
  float d2 = dot(z-r2, z-r2);
  float d3 = dot(z-r3, z-r3);

  float rootPhase = 0.0;
  if (d1 < d0 && d1 < d2 && d1 < d3) rootPhase = 0.25;
  else if (d2 < d0 && d2 < d1 && d2 < d3) rootPhase = 0.5;
  else if (d3 < d0 && d3 < d1 && d3 < d2) rootPhase = 0.75;

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime*0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
