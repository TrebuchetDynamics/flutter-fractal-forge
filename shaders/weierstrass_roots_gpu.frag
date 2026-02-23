#include <flutter/runtime_effect.glsl>

precision highp float;

// Weierstrass cubic root-finding: Newton's method on f(z) = 4z³ − g₂z
// with g₂ = 4 (square/lemniscate lattice, g₃ = 0).
// Three roots: e₃ = 0,  e₁ = +1,  e₂ = −1  (the Weierstrass e-values).
// The Weierstrass ℘-function for this lattice satisfies (℘')² = 4℘³ − 4℘,
// so these roots are the critical values ℘(ω₁/2), ℘(ω₂/2), ℘((ω₁+ω₂)/2).
// Basin boundaries form a fractal Julia-like curve.
// Supports normal-map shading (colorScheme 50-63) via analytic N'(z).
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
  vec2 z   = uv / max(0.000001, uZoom) + uCenter;
  vec2 der = vec2(1.0, 0.0);

  // f(z) = 4z³ − 4z,  f'(z) = 12z² − 4,  f''(z) = 24z
  // Newton: z ← z − f/f'
  // N'(z) = f(z)·f''(z) / f'(z)²  (derivative of Newton operator)
  const float G2 = 4.0;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 z2  = cmul(z, z);
    vec2 z3  = cmul(z2, z);
    vec2 fz  = 4.0*z3 - G2*z;                    // f(z) = 4z³ − 4z
    vec2 fpz = 12.0*z2 - vec2(G2, 0.0);           // f'(z) = 12z² − 4
    float dfp = dot(fpz, fpz);
    if (dfp < 1e-20) break;

    // N'(z) = f(z)·f''(z) / f'(z)²  where f''(z) = 24z
    vec2 fppz  = 24.0*z;
    vec2 Nprime = cdiv(cmul(fz, fppz), cmul(fpz, fpz));
    der = cmul(Nprime, der);

    vec2 step = cdiv(fz, fpz);
    z = z - step;

    if (dot(step, step) < 1e-14) { it = j; break; }
    if (dot(z, z) > max(uBailout*uBailout, 64.0)) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  // Three roots: e₃=(0,0), e₁=(1,0), e₂=(−1,0)
  float d0 = dot(z,            z);
  float d1 = dot(z-vec2( 1,0), z-vec2( 1,0));
  float d2 = dot(z-vec2(-1,0), z-vec2(-1,0));
  float rootPhase;
  if (d0 <= d1 && d0 <= d2) rootPhase = 0.0;
  else if (d1 <= d0 && d1 <= d2) rootPhase = 0.33333333;
  else rootPhase = 0.66666667;

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime*0.0001);

  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom   = max(1e-12, dot(der, der));
    vec2 nv       = vec2(z.x*der.x+z.y*der.y, z.y*der.x-z.x*der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv,lightDir)+HEIGHT)/(1.0+HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0/1.8);
    int basePal = (schemeInt-50) % 4;
    fragColor = vec4(linearToSRGB(palette(t, basePal)*light), 1.0);
    return;
  }

  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
