#include <flutter/runtime_effect.glsl>

precision highp float;

// Cosine Mandelbrot: z_{n+1} = cos(z) + c
// Transcendental escape-time fractal with infinite period-doubling structure.
// Derivative: d(cos(z))/dc = −sin(z)·der + 1.
// cos(z) is clamped before eval to prevent cosh overflow → NaN.
// Supports normal-map shading (colorScheme 50-63).
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uVariant;

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int MAX_ITERS = 220;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

// colorScheme 0-49: standard palette coloring.
// colorScheme 50-63: normal-map (bas-relief) mode — 14 light angles × 4 base palettes.
vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.33,0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.10,0.20));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.0,0.15,0.20));
  if (scheme == 3) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0));
  float s = float(scheme);
  vec3 a = vec3(0.5 + 0.2*sin(s*1.1), 0.5 + 0.2*sin(s*1.3), 0.5 + 0.2*sin(s*1.7));
  vec3 b = vec3(0.5 + 0.3*cos(s*0.7), 0.5 + 0.3*cos(s*1.1), 0.5 + 0.3*cos(s*0.3));
  vec3 c = vec3(1.0 + sin(s*0.5), 1.0 + sin(s*0.9), 1.0 + sin(s*1.3));
  vec3 d = vec3(fract(s*0.13), fract(s*0.17), fract(s*0.23));
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-12);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}
vec2 clogSafe(vec2 z) { return vec2(log(max(length(z), 1e-12)), atan(z.y, z.x)); }

vec2 csin(vec2 z) {
  float y = clamp(z.y, -12.0, 12.0);
  return vec2(sin(z.x)*cosh(y), cos(z.x)*sinh(y));
}
vec2 ccos(vec2 z) {
  float y = clamp(z.y, -12.0, 12.0);
  return vec2(cos(z.x)*cosh(y), -sin(z.x)*sinh(y));
}

vec2 evalVariant(vec2 z, vec2 c, int variant) {
  if (variant == 1) return clogSafe(ccos(z)) + c; // log(cos(z))+c
  if (variant == 2) return ccos(z) + vec2(1.0, 0.0) + c; // cos(z)+1+c
  if (variant == 3) return cmul(ccos(z), z) + c; // z cos(z)+c
  if (variant == 4) return z + cdiv(ccos(z), csin(z)) + c; // Newton-cosine + c
  return ccos(z) + c; // cos(z)+c
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c   = uv / max(uZoom, 1e-6) + uCenter;
  vec2 z   = vec2(0.0);
  vec2 der = vec2(0.0);

  float bailoutSq = max(4.0, uBailout * uBailout);
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target;
  bool needsDerivative = schemeInt >= 50;
  float orbit = 0.0;
  float trap = 1e9;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;
    // Clamp before transcendental to prevent cosh overflow.
    vec2 zc = vec2(clamp(z.x, -12.0, 12.0), clamp(z.y, -12.0, 12.0));
    int variant = int(uVariant);
    vec2 f0 = evalVariant(zc, c, variant);
    if (needsDerivative) {
      float eps = 1e-4;
      vec2 dFdz = (evalVariant(zc + vec2(eps, 0.0), c, variant) -
                   evalVariant(zc - vec2(eps, 0.0), c, variant)) / (2.0 * eps);
      der = cmul(dFdz, der) + vec2(1.0, 0.0);
    }
    z = f0;
    float mag2 = dot(z, z);
    orbit += exp(-0.35 * mag2);
    trap = min(trap, min(abs(z.x), abs(z.y)));
    if (mag2 > bailoutSq || mag2 != mag2) { it = j; break; }
  }

  if (it >= target) {
    float n = clamp(orbit / max(1.0, float(target)), 0.0, 1.0);
    float tBound = fract(0.7 * n - 0.12 * log(max(trap, 1e-6)) + float(int(uVariant)) * 0.17 + uTime * 0.0001);
    vec3 col = getPaletteColor(tBound, schemeInt) * (0.35 + 0.65 * n);
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float mag2      = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));

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

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(getPaletteColor(t, schemeInt)), 1.0);
}
