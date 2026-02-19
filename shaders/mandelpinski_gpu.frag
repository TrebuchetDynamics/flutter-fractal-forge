#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelpinski necklaces: F_λ(z) = z² + λ/z²  (Devaney's singular perturbation family)
// Parameter space — each pixel is λ, iterated from the principal critical value z₀ = √λ.
// "Necklaces" = concentric rings of baby Mandelbrot copies separated by Cantor-circle
// dust around the origin.  Dual escape: to ∞ (|z|>R) and to the pole-trap (|z|<ε).
// Derivative tracks ∂z/∂λ for normal-map shading (colorScheme 50-63).
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

// Principal-branch complex square root
vec2 csqrt(vec2 z) {
  float r = length(z);
  float re = sqrt(max(0.0, (r + z.x) * 0.5));
  float im = (z.y >= 0.0 ? 1.0 : -1.0) * sqrt(max(0.0, (r - z.x) * 0.5));
  return vec2(re, im);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 lam = uv / max(0.000001, uZoom) + uCenter;  // parameter λ (each pixel)

  // Start from principal critical value z₀ = √λ
  vec2 z = csqrt(lam);
  // ∂z₀/∂λ = 1/(2√λ) = 0.5/z₀
  vec2 der = cdiv(vec2(0.5, 0.0), z);

  float bailoutSq = uBailout * uBailout;
  const float TRAP_SQ = 1e-8;   // origin-pole trap radius²
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  bool trapped = false;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 z2 = cmul(z, z);          // z²
    float d2 = dot(z2, z2);        // |z²|²
    if (d2 < TRAP_SQ) { it = j; trapped = true; break; }  // pole trap

    // Derivative (parameter space): ∂z/∂λ
    // F(z,λ) = z² + λ/z²  →  ∂F/∂z = 2z − 2λ/z³,  ∂F/∂λ = 1/z²
    vec2 z3     = cmul(z2, z);
    vec2 dFdz   = 2.0*z - cdiv(2.0*lam, z3);
    vec2 dFdlam = cdiv(vec2(1.0, 0.0), z2);
    der = cmul(dFdz, der) + dFdlam;

    z = z2 + cdiv(lam, z2);        // F_λ(z) = z² + λ/z²
    if (dot(z,z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target && !trapped) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal;
  if (trapped) {
    // Origin-trap smooth: use 1/mag2 so log arguments stay positive
    smoothVal = float(it) + 1.0 - log2(max(1e-6, -log2(mag2)));
  } else {
    smoothVal = float(it) - log2(log2(mag2));
  }

  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2(z.x*der.x+z.y*der.y, z.y*der.x-z.x*der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv,lightDir)+HEIGHT)/(1.0+HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0/1.8);
    float baseT = fract(smoothVal/64.0 + uTime*0.0001);
    int basePal = (schemeInt-50) % 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal)*light), 1.0);
    return;
  }

  // Shift hue for origin-trapped vs infinity-escaped points
  float offset = trapped ? 0.33 : 0.0;
  float t = fract(smoothVal/64.0 + offset + uTime*0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
