#include <flutter/runtime_effect.glsl>

precision highp float;

// Generalized McMullen Map: z → z^n + a / z^m + b
// Extends the classic McMullen rational map by allowing independent powers
// for the polynomial and reciprocal terms, plus an additive constant b.
// Creates asymmetric fractal Julia sets with rich spiral and filament structure
// when n != m. The rotational symmetry is governed by gcd(n,m).
// Derivative: f'(z) = n*z^(n-1) - m*a*z^{-(m+1)}
// Chain rule: der_new = f'(z) * der_old
// Extra params: uPowerN (10), uPowerM (11), uAReal (12), uAImag (13),
//               uBReal (14), uBImag (15).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uPowerN;        // 10  (default 3, range 2..8)
uniform float uPowerM;        // 11  (default 3, range 1..8)
uniform float uAReal;         // 12  (default -0.1)
uniform float uAImag;         // 13  (default 0.0)
uniform float uBReal;         // 14  (default 0.0)
uniform float uBImag;         // 15  (default 0.0)

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
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c*t+d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

vec2 cdiv(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-20);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}

// Complex integer power: z^p for integer p >= 0 (max 8).
vec2 cpow(vec2 z, int p) {
  vec2 result = vec2(1.0, 0.0);
  for (int i = 0; i < 8; i++) {
    if (i >= p) break;
    result = cmul(result, z);
  }
  return result;
}

// Compute z^p and z^(p-1) simultaneously for derivative.
void cpow_and_prev(vec2 z, int p, out vec2 zp, out vec2 zp1) {
  zp  = vec2(1.0, 0.0);
  zp1 = vec2(1.0, 0.0);
  for (int i = 0; i < 8; i++) {
    if (i >= p) break;
    if (i == p - 1) zp1 = zp;
    zp = cmul(zp, z);
  }
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  int pn = int(clamp(uPowerN, 2.0, 8.0));
  int pm = int(clamp(uPowerM, 1.0, 8.0));
  float nf = float(pn);
  float mf = float(pm);
  vec2 aCoeff = vec2(uAReal, uAImag);
  vec2 bCoeff = vec2(uBReal, uBImag);

  // Julia-set style: z0 = pixel coordinate
  vec2 z   = uv / max(0.000001, uZoom) + uCenter;
  // Chain-rule derivative for normal-map shading
  vec2 der = vec2(1.0, 0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Compute z^n and z^(n-1)
    vec2 zn, zn1;
    cpow_and_prev(z, pn, zn, zn1);

    // Compute z^m
    vec2 zm = cpow(z, pm);
    vec2 zmInv = cdiv(vec2(1.0, 0.0), zm);

    // Derivative: f'(z) = n * z^(n-1) - m * a * z^{-(m+1)}
    // z^{-(m+1)} = z^{-m} / z = zmInv / z
    vec2 zmp1Inv = cdiv(zmInv, z);
    vec2 fprime = nf * zn1 - mf * cmul(aCoeff, zmp1Inv);
    der = cmul(fprime, der);

    // Map: z_new = z^n + a * z^{-m} + b
    z = zn + cmul(aCoeff, zmInv) + bCoeff;

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  // Dominant escape power is max(n, m) for large |z| (polynomial term dominates).
  float escPow = max(nf, 2.0);
  float smoothVal = float(it) - log2(log2(mag2)) / log2(escPow);

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
