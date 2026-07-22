#include <flutter/runtime_effect.glsl>

precision highp float;

// Sine Mandelbrot — from MandlebrotSetSFML formula #5.
// z_{n+1} = sin(z) + c.
// Complex sine applied in Mandelbrot mode creates infinite period-doubling
// bands separated by the sin singularity structure — produces swirling
// spiral arms distinct from the cosine variant.
// Derivative: d(sin(z))/dc = cos(z)·der + 1.
//   cos(z) = cos(x)cosh(y) − i·sin(x)sinh(y).
// Imaginary part clamped before cosh/sinh to prevent overflow.
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

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.7))
    );
  } else if (scheme == 1) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.0))
    );
  } else if (scheme == 2) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }

vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b, b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

#define CEXP_CLAMP -20.0
vec2 cexp(vec2 z) {
  float ex = exp(clamp(z.x, CEXP_CLAMP, -CEXP_CLAMP));
  return ex * vec2(cos(z.y), sin(z.y));
}

vec2 clogSafe(vec2 z) { return vec2(log(max(length(z), 1e-12)), atan(z.y, z.x)); }

// Complex sin: sin(x+iy) = sin(x)cosh(y) + i·cos(x)sinh(y)
// Clamp imaginary part to prevent cosh/sinh overflow.
vec2 csin(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(sin(z.x)*cosh(y), cos(z.x)*sinh(y));
}
// Complex cos: cos(x+iy) = cos(x)cosh(y) − i·sin(x)sinh(y)
vec2 ccos(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(cos(z.x)*cosh(y), -sin(z.x)*sinh(y));
}
vec2 csinh(vec2 z) {
  float x = clamp(z.x, -20.0, 20.0);
  return vec2(sinh(x)*cos(z.y), cosh(x)*sin(z.y));
}
vec2 ccosh(vec2 z) {
  float x = clamp(z.x, -20.0, 20.0);
  return vec2(cosh(x)*cos(z.y), sinh(x)*sin(z.y));
}

vec2 evalVariant(vec2 z, vec2 c, int variant) {
  if (variant == 1) return csin(cdiv(vec2(1.0, 0.0), z)) + c; // sin(1/z)+c
  if (variant == 2) return cmul(csin(z), ccos(z)) + c; // sin(z)cos(z)+c
  if (variant == 3) return cmul(csinh(z), ccosh(z)) + c; // sinh(z)cosh(z)+c
  if (variant == 4) return clogSafe(csin(z)) + c; // log(sin(z))+c
  if (variant == 5) return cmul(csin(z), z) + c; // z sin(z)+c
  if (variant == 6) return csin(z) + vec2(1.0, 0.0) + c; // sin(z)+1+c
  if (variant == 7) return csinh(z) + c; // sinh(z)+c
  if (variant == 8) return cmul(cexp(z), csin(z)) + c; // exp(z)sin(z)+c
  if (variant == 9) {
    vec2 a = vec2(cos(0.7), sin(0.7));
    vec2 d = vec2(cos(0.7), -sin(0.7));
    return cdiv(cmul(a, z) + vec2(1.0, 0.0), z + d);
  }
  if (variant == 10) return cexp(cmul(z, z)) + c; // exp(z²)+c
  if (variant == 11) return clogSafe(cmul(z, z)) + c; // log(z²)+c
  if (variant == 12) return cexp(cdiv(vec2(1.0, 0.0), z)) + c; // exp(1/z)+c
  if (variant == 13) return cmul(z, cdiv(csin(z), ccos(z))) + c; // z·tan(z)+c
  if (variant == 14) return cmul(z, cexp(-cmul(z, z))) + c; // z·exp(-z²)+c
  if (variant == 15) return cexp(vec2(-z.y, z.x)) + c; // exp(i·z)+c
  if (variant == 16) return cexp(z) + z + c; // exp(z)+z+c
  return csin(z) + c; // sin(z)+c
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);
  int schemeInt = int(uColorScheme);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 c0 = c;
  int variant = int(uVariant);
  vec2 z = (variant == 9 || variant == 11 || variant == 12) ? c : vec2(0.0);
  vec2 der = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  // ponytail: shader cap matches shared catalog deep-zoom issue settings.
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  float trap = 1e6;
  float orbit = 0.0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 f0 = evalVariant(z, c, variant);
    if (schemeInt >= 50) {
      float eps = 1e-4;
      vec2 dFdz = (evalVariant(z + vec2(eps, 0.0), c, variant) -
                   evalVariant(z - vec2(eps, 0.0), c, variant)) / (2.0 * eps);
      der = cmul(dFdz, der) + vec2(1.0, 0.0);
    }
    z = f0;

    float mag2 = dot(z, z);
    trap = min(trap, min(abs(z.x), abs(z.y)));
    orbit += exp(-2.0 * mag2);
    if (mag2 > bailoutSq || mag2 != mag2) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    float singularGlow = exp(-12.0 * trap);
    float contour = 0.18 * sin(9.0 * c0.x + 5.0 * c0.y) +
        0.12 * cos(17.0 * length(c0));
    float t = fract(6.0 * trap + orbit / max(1.0, float(target)) +
        0.18 * singularGlow + 0.07 * atan(z.y, z.x) + contour +
        uTime * 0.00005);
    vec3 col = palette(t, schemeInt) * (0.55 + 0.45 * singularGlow);
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.85 : 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x*der.x + z.y*der.y,
                    z.y*der.x - z.x*der.y) / denom;
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

  float contour = 0.18 * sin(9.0 * c0.x + 5.0 * c0.y) +
      0.12 * cos(17.0 * length(c0));
  float t = fract(smoothVal / 64.0 + contour + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
