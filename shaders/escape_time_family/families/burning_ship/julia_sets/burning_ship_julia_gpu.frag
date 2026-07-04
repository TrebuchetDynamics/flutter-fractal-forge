#include <flutter/runtime_effect.glsl>

precision highp float;

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

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

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
vec2 cadd(vec2 a, vec2 b) { return a + b; }
vec2 csub(vec2 a, vec2 b) { return a - b; }
vec2 cconj(vec2 z) { return vec2(z.x, -z.y); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = max(dot(b,b), 1e-12);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}
vec2 cpow2(vec2 z) { return cmul(z,z); }
vec2 cpow3(vec2 z) { return cmul(cpow2(z), z); }
vec2 cexp(vec2 z) {
  float ex = exp(clamp(z.x, -40.0, 40.0));
  return ex * vec2(cos(z.y), sin(z.y));
}
vec2 csin(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(sin(z.x)*cosh(y), cos(z.x)*sinh(y));
}
vec2 ccos(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(cos(z.x)*cosh(y), -sin(z.x)*sinh(y));
}
vec2 ctan(vec2 z) { return cdiv(csin(z), ccos(z)); }
vec2 csinh(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(sinh(z.x)*cos(y), cosh(z.x)*sin(y));
}
vec2 ccosh(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(cosh(z.x)*cos(y), sinh(z.x)*sin(y));
}
vec2 ctanh(vec2 z) { return cdiv(csinh(z), ccosh(z)); }

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  // Keep the standard Burning Ship upright orientation while preserving the
  // shared screen-pan convention: display y is flipped before the recurrence,
  // and the center is flipped by the same transform.
  vec2 z = vec2(uv.x, -uv.y) / max(uZoom, 1e-6) +
           vec2(uCenter.x, -uCenter.y);
  vec2 cSeed = vec2(-0.52, -0.42);
  // dz/dz0 derivative. Burning Ship Julia: z = abs(z)^2 + cSeed.
  // dw/dz0 = (sign(z.x)*der.x, sign(z.y)*der.y); der = 2*cmul(abs(z), dw)
  vec2 der = vec2(1.0, 0.0);
  float trap = 1e9;
  float orbit = 0.0;
  float stripe = 0.0;

  float bailoutSq = max(4.0, uBailout * uBailout);
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;

    vec2 za = vec2(abs(z.x), abs(z.y));
    vec2 derw = vec2(sign(z.x) * der.x, sign(z.y) * der.y);
    der = 2.0 * cmul(za, derw);
    z = cpow2(za) + cSeed;

    float mag2 = dot(z, z);
    trap = min(trap, min(min(abs(z.x), abs(z.y)), abs(sqrt(mag2) - 1.0)));
    orbit += exp(-1.7 * mag2);
    stripe += 0.5 + 0.5 * sin(8.0 * atan(z.y, z.x) + 0.35 * float(j));
    if (mag2 > bailoutSq) { it = j; break; }
  }

  float sampleCount = max(1.0, float(it));
  float orbitAvg = orbit / sampleCount;
  float stripeAvg = stripe / sampleCount;
  float trapGlow = exp(-9.0 * trap);

  if (it >= target) {
    float phase = atan(z.y, z.x) / 6.28318530718 + 0.5;
    float tBound = fract(phase + 0.34 * orbitAvg + 0.24 * trapGlow + 0.12 * stripeAvg + uTime * 0.0001);
    vec3 col = getPaletteColor(tBound, schemeInt) * (0.46 + 0.34 * orbitAvg + 0.20 * trapGlow);
    col += 0.16 * vec3(trapGlow, orbitAvg, stripeAvg);
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float smoothVal = float(it) - log2(log2(max(1e-12, dot(z, z))));

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

  float folds = smoothstep(0.26, 0.54, abs(sin(11.0 * z.x - 13.0 * z.y + 17.0 * uv.x + 5.0 * uv.y)));
  float t = fract(smoothVal / 56.0 + 0.10 * folds + 0.08 * trapGlow + 0.05 * orbitAvg + uTime * 0.0001);
  vec3 col = getPaletteColor(t, schemeInt) * (0.56 + 0.26 * folds + 0.18 * trapGlow);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
