#include <flutter/runtime_effect.glsl>

precision highp float;

// Weierstrass ℘-function parameter space: z → ℘(z) + c
// Each pixel is the parameter c; orbit starts from the critical point
// z₀ = (0.5, 0.5) of the square lattice Λ = ℤ + iℤ.
// ℘ is computed via an 8-term first-shell lattice sum:
//   ℘(z) = 1/z² + Σ'_{|m|≤1,|n|≤1} ( 1/(z−(m+in))² − 1/(m+in)² )
// Poles at all lattice points create rich escape topology.
// Derivative ∂z/∂c (via ℘') gives accurate normal-map shading (scheme 50-63).
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

// Returns ℘(z) and sets prime_out = ℘'(z).
// Square lattice Λ = ℤ+iℤ, 8-term first-shell approximation.
vec2 wp(vec2 z, out vec2 prime_out) {
  // z = 0 lattice pole
  vec2 z2 = cmul(z, z);
  float dz2 = dot(z2, z2);
  if (dz2 < 1e-8) { prime_out = vec2(1e10, 0.0); return vec2(1e10, 0.0); }
  vec2 result = cdiv(vec2(1.0, 0.0), z2);
  vec2 z3     = cmul(z2, z);
  prime_out   = cdiv(vec2(-2.0, 0.0), z3);

  for (int m = -1; m <= 1; m++) {
    for (int n = -1; n <= 1; n++) {
      if (m == 0 && n == 0) continue;
      vec2 w   = vec2(float(m), float(n));
      vec2 zm  = z - w;
      float d  = dot(zm, zm);         // |z − w|²
      if (d < 1e-8) { prime_out = vec2(1e10, 0.0); return vec2(1e10, 0.0); }
      vec2 zm2 = cmul(zm, zm);
      vec2 zm3 = cmul(zm2, zm);
      vec2 w2  = cmul(w, w);
      result    += cdiv(vec2(1.0, 0.0), zm2) - cdiv(vec2(1.0, 0.0), w2);
      prime_out += cdiv(vec2(-2.0, 0.0), zm3);
    }
  }
  return result;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;  // parameter c

  // Critical point of square-lattice ℘: z₀ = (½, ½)
  // ℘((½,½)) = 0 for the square lattice, so z₁ = c exactly.
  vec2 z   = vec2(0.5, 0.5);
  vec2 der = vec2(0.0, 0.0);  // ∂z₀/∂c = 0

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 wp_prime;
    vec2 wp_val = wp(z, wp_prime);

    if (dot(wp_val, wp_val) > bailoutSq) { it = j; break; }
    if (wp_val.x > 1e8) { it = j; break; }  // pole hit

    // ∂z_{n+1}/∂c = ℘'(z_n) · ∂z_n/∂c + 1
    der = cmul(wp_prime, der) + vec2(1.0, 0.0);
    z   = wp_val + c;
    it  = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  float mag2     = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));

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
    float baseT = fract(smoothVal/64.0 + uTime*0.0001);
    int basePal = (schemeInt-50) % 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal)*light), 1.0);
    return;
  }

  float t = fract(smoothVal/64.0 + uTime*0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
