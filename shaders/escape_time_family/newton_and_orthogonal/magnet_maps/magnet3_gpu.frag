#include <flutter/runtime_effect.glsl>

precision highp float;

// Magnet Type III (custom rational map):
//   z = ((z⁴ + kA·z² + kB) / (kC·z³ + kD·z + kE))² + 0.12·p
// where p is the screen coordinate (Julia-like) and kA..kE are fixed complex
// constants. The 0.12·p coupling creates parameter-space variation.
// Derivative dz/dp (initial der = 1 since z₀ = p):
//   dnum/dp = (4z³ + 2kA·z)·der
//   dden/dp = (3kC·z² + kD)·der
//   dq/dp   = (dnum·den − num·dden) / den²
//   dz/dp   = 2q · dq/dp + 0.12
// Supports normal-map shading (colorScheme 50-63).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

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

// colorScheme 0-49: standard palette coloring.
// colorScheme 50-63: normal-map (bas-relief) mode — 14 light angles × 4 base palettes.
vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  } else if (scheme == 1) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  } else if (scheme == 2) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c4 = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c4 * t + d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cdivSafe(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-20);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = p;
  // Julia-style: der = dz/dp, initial dz₀/dp = 1
  vec2 der = vec2(1.0, 0.0);

  const vec2 kA = vec2(0.42, -0.18);
  const vec2 kB = vec2(-0.31, 0.24);
  const vec2 kC = vec2(0.73, 0.11);
  const vec2 kD = vec2(-0.26, -0.39);
  const vec2 kE = vec2(0.85, 0.07);

  float bailoutSq = uBailout * uBailout;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  float trap = 1e6;
  float orbit = 0.0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 z2  = cmul(z, z);
    vec2 z3  = cmul(z2, z);
    vec2 z4  = cmul(z2, z2);

    vec2 num = z4 + cmul(kA, z2) + kB;
    vec2 den = cmul(kC, z3) + cmul(kD, z) + kE;
    vec2 q   = cdivSafe(num, den);

    // Quotient-rule derivative dz/dp
    vec2 dnum = cmul(4.0 * z3 + 2.0 * cmul(kA, z), der);
    vec2 dden = cmul(3.0 * cmul(kC, z2) + kD, der);
    vec2 dq   = cdivSafe(cmul(dnum, den) - cmul(num, dden), cmul(den, den));
    der = 2.0 * cmul(q, dq) + vec2(0.12, 0.0);

    z = cmul(q, q) + 0.12 * p;

    float mag2 = dot(z, z);
    trap = min(trap, min(length(den), length(z - p)));
    orbit += exp(-mag2);
    if (mag2 > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    float ridge = exp(-8.0 * trap);
    float t = fract(0.45 * ridge + orbit / max(1.0, float(target)) + 0.09 * atan(z.y, z.x) + uTime * 0.00005);
    vec3 col = palette(t, schemeInt) * (0.55 + 0.45 * ridge);
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.85 : 1.0);
    return;
  }

  float mag2      = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2 + 1.0));

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
