#include <flutter/runtime_effect.glsl>

precision highp float;

// Lambert W fractal: z_{n+1} = W(z_n) + c  (principal branch, Newton iterations).
// Julia-style with additive c: z₀=c=pixel, der₀=(1,0).
// Derivative d/dc: der_{n+1} = W'(z_n)·der_n + 1,
//   W'(z) = W(z) / (z·(1+W(z))),  W'(0) = 1.
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
vec2 cdiv(vec2 a, vec2 b) {
  float d = max(1e-8, dot(b, b));
  return vec2((a.x * b.x + a.y * b.y) / d, (a.y * b.x - a.x * b.y) / d);
}

vec2 lambertW(vec2 z) {
  vec2 w = (length(z) < 1.0) ? z : vec2(log(max(length(z), 1e-6)), atan(z.y, z.x));
  for (int i = 0; i < 7; i++) {
    vec2 ew = exp(w.x) * vec2(cos(w.y), sin(w.y));
    vec2 f = cmul(w, ew) - z;
    vec2 fp = ew * (w + vec2(1.0, 0.0));
    w -= cdiv(f, fp);
  }
  return w;
}

// W'(z) = W(z) / (z·(1+W(z))).  At z≈0 returns (1,0).
vec2 lambertWDeriv(vec2 z, vec2 wz) {
  float zLen2 = dot(z, z);
  if (zLen2 < 1e-16) return vec2(1.0, 0.0);
  return cdiv(wz, cmul(z, wz + vec2(1.0, 0.0)));
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fc - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = c;
  vec2 der = vec2(1.0, 0.0);  // dz₀/dc = 1 (Julia-style with additive c)

  float bailoutSq = max(4.0, uBailout * uBailout);
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }
    vec2 wz = lambertW(z);
    // der_{n+1} = W'(z_n)·der_n + 1
    der = cmul(lambertWDeriv(z, wz), der) + vec2(1.0, 0.0);
    z = wz + c;
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

  float t = fract(smoothVal / 64.0 + uTime * 0.00008);
  fragColor = vec4(linearToSRGB(getPaletteColor(t, schemeInt)), 1.0);
}
