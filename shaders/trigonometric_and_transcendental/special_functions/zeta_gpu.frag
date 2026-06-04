#include <flutter/runtime_effect.glsl>

precision highp float;

// Zeta fractal: z_{n+1} = ζ(z_n) + c  (partial Dirichlet sum ≈ Riemann zeta).
// Julia-style with mutating c: z₀=c=pixel, der₀=(1,0).
// Derivative d/dc: der_{n+1} = ζ'(z_n)·der_n + 1,
//   ζ'(s) = -Σ_{n=2}^N log(n)·n^{-s}  (n=1 term vanishes since log(1)=0).
// Supports normal-map shading (colorScheme 50-63).
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

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

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b * cos(6.28318 * (c * t + d)); }
vec3 getPaletteColor(float t, int s) {
  t = fract(t);
  if (s == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (s == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.00, 0.15, 0.20));
  if (s == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));
  float fs = float(s);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37 * fs + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29 * fs + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11 * fs + 0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (fs + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }

vec2 zetaApprox(vec2 s, int terms) {
  vec2 sum = vec2(0.0);
  for (int n = 1; n <= 32; n++) {
    if (n > terms) break;
    float lnN = log(float(n));
    float amp = exp(-s.x * lnN);
    float ph = -s.y * lnN;
    sum += amp * vec2(cos(ph), sin(ph));
  }
  return sum;
}

// ζ'(s) = -Σ_{n=2}^N log(n)·n^{-s}
vec2 zetaApproxDeriv(vec2 s, int terms) {
  vec2 sum = vec2(0.0);
  for (int n = 2; n <= 32; n++) {
    if (n > terms) break;
    float lnN = log(float(n));
    float amp = exp(-s.x * lnN);
    float ph = -s.y * lnN;
    sum -= lnN * amp * vec2(cos(ph), sin(ph));
  }
  return sum;
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fc - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = c;
  vec2 der = vec2(1.0, 0.0);  // dz₀/dc = 1 (Julia-style with additive c)

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int terms = int(clamp(6.0 + float(target) * 0.05, 6.0, 32.0));
  float bailoutSq = max(4.0, uBailout * uBailout);
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }
    // der_{n+1} = ζ'(z_n)·der_n + 1
    der = cmul(zetaApproxDeriv(z, terms), der) + vec2(1.0, 0.0);
    z = zetaApprox(z, terms) + c;
    if (dot(z, z) > bailoutSq) { it = i; break; }
    it = i + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-8, dot(z, z));
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
    fragColor = vec4(linearToSRGB(getPaletteColor(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + 0.015 * float(terms) + uTime * 0.00007);
  fragColor = vec4(linearToSRGB(getPaletteColor(t, schemeInt)), 1.0);
}
