#include <flutter/runtime_effect.glsl>

precision highp float;

// Jim Muth / Fractint Fractal-of-the-Day shared renderer.
// Provenance: https://user.xmission.com/~legalize/fractals/fotd/ parameter
// archive plus Fractint formula definitions in fotdv*.frm. This shader covers
// the highest-frequency FOTD formulas with reviewed GLSL equivalents.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uVariant;       // 10
uniform float uCoeffA;        // 11
uniform float uPowerB;        // 12
uniform float uCoeffD;        // 13
uniform float uPowerF;        // 14
uniform float uCoeffG;        // 15
uniform float uPowerH;        // 16
uniform float uCoeffJ;        // 17
uniform float uPowerK;        // 18
uniform float uSeedX;         // 19
uniform float uSeedY;         // 20

out vec4 fragColor;

const float PI = 3.14159265358979323846;
const float TAU = 6.28318530717958647692;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5 + 0.5 * cos(TAU * (t + 0.00)),
                0.5 + 0.5 * cos(TAU * (t + 0.37)),
                0.5 + 0.5 * cos(TAU * (t + 0.71)));
  }
  if (scheme == 1) {
    return vec3(0.08 + 0.92 * t, 0.18 + 0.65 * sqrt(t), 1.0 - 0.75 * t);
  }
  if (scheme == 2) {
    return vec3(smoothstep(0.0, 1.0, t), smoothstep(0.18, 0.82, t), 0.35 + 0.65 * (1.0 - t));
  }
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(TAU * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.54 + 0.16 * sin(vec3(1.0, 2.0, 3.0) * (0.31 * s + 0.13));
  vec3 b = 0.42 + 0.24 * cos(vec3(1.7, 2.3, 2.9) * (0.23 * s + 0.19));
  vec3 c = 1.00 + 0.75 * sin(vec3(0.8, 1.3, 1.7) * (0.09 * s + 0.29));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(TAU * (c * t + d)), 0.0, 1.0);
}

vec2 cx_mul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cx_div(vec2 a, vec2 b) {
  float den = max(dot(b, b), 1e-12);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / den;
}

vec2 cx_log(vec2 z) {
  return vec2(0.5 * log(max(dot(z, z), 1e-24)), atan(z.y, z.x));
}

vec2 cx_exp(vec2 z) {
  float e = exp(clamp(z.x, -20.0, 20.0));
  return vec2(e * cos(z.y), e * sin(z.y));
}

vec2 cx_pow_real(vec2 z, float p) {
  float r = max(length(z), 1e-12);
  float theta = atan(z.y, z.x);
  float rp = exp(clamp(p * log(r), -20.0, 20.0));
  return rp * vec2(cos(p * theta), sin(p * theta));
}

vec2 mixCriticalPoint(float a, float b, float d, float f) {
  float safeF = abs(f) < 1e-5 ? (f < 0.0 ? -1e-5 : 1e-5) : f;
  float safeD = abs(d) < 1e-5 ? (d < 0.0 ? -1e-5 : 1e-5) : d;
  float denom = f - b;
  denom = abs(denom) < 1e-5 ? (denom < 0.0 ? -1e-5 : 1e-5) : denom;
  float base = -a * b * (1.0 / safeF) * (1.0 / safeD);
  return cx_pow_real(vec2(base, 0.0), 1.0 / denom);
}

void julibrotSlice(vec2 pixel, out vec2 c, out vec2 z) {
  float u = pixel.x;
  float v = pixel.y;
  float aa = PI * uCoeffA / 180.0;
  float bb = PI * uPowerB / 180.0;
  float gg = PI * uCoeffD / 180.0;
  float dd = PI * uPowerF / 180.0;
  float ca = cos(aa);
  float cb = cos(bb);
  float sb = sin(bb);
  float cg = cos(gg);
  float sg = sin(gg);
  float cd = cos(dd);
  float sd = sin(dd);
  float p = u * cg * cd - v * (ca * sb * sg * cd + ca * cb * sd);
  float q = u * cg * sd + v * (ca * cb * cd - ca * sb * sg * sd);
  float r = u * sg + v * ca * sb * cg;
  float s = v * sin(aa);
  c = vec2(p, q) + vec2(uCoeffG, uPowerH);
  z = vec2(r, s) + vec2(uCoeffJ, uPowerK);
}

vec2 fotdFn1(vec2 z) {
  return sin(z.x) * vec2(cosh(clamp(z.y, -8.0, 8.0)), cos(z.y));
}

vec2 cx_cos(vec2 z) {
  float y = clamp(z.y, -8.0, 8.0);
  return vec2(cos(z.x) * cosh(y), -sin(z.x) * sinh(y));
}

vec2 fotdIterate(vec2 z, vec2 pixel, int variant) {
  float a = uCoeffA;
  float b = uPowerB;
  float d = uCoeffD;
  float f = uPowerF;

  if (variant == 2) {
    // MandelbrotMix6: z = a*z^b + d*z^f + pixel*k.
    return a * cx_pow_real(z, b) + d * cx_pow_real(z, f) + pixel * uCoeffG;
  }

  if (variant == 3) {
    // MandelbrotMix3a: four weighted powers plus c.
    return a * cx_pow_real(z, b) +
           d * cx_pow_real(z, f) +
           uCoeffG * cx_pow_real(z, uPowerH) +
           uCoeffJ * cx_pow_real(z, uPowerK) + pixel;
  }

  if (variant == 4) {
    // MandelbrotN: z = z^p + c.
    return cx_pow_real(z, b) + pixel + vec2(uSeedX, uSeedY);
  }

  if (variant == 5) {
    // MandelbrotMiN: z = (-z)^p + c.
    return cx_pow_real(-z, b) + pixel + vec2(uSeedX, uSeedY);
  }

  if (variant == 6 || variant == 7 || variant == 13 || variant == 14) {
    // Mandelbrot/Julia BC: branch-cut logarithmic power map.
    vec2 e = vec2(a, b);
    float p = uSeedX + PI;
    float q = TAU * floor(p / TAU);
    float r = (variant == 7) ? (uSeedX + PI - q) : (uSeedX - q);
    vec2 w = cx_log(z);
    if (w.y > r) {
      w.y += TAU;
    }
    w.y += q;
    vec2 c = (variant == 13) ? vec2(uCoeffG, uPowerH) : pixel;
    return cx_exp(cx_mul(e, w)) + c;
  }

  if (variant == 8 || variant == 15) {
    // DivideBrot5 / FinDivBrot-2 / DivideJulibrot family.
    float aa = a - 2.0;
    float bb = max(abs(b), 1e-8);
    vec2 denom = cx_pow_real(z, -aa) + vec2(bb, 0.0);
    return cx_div(cx_mul(z, z), denom) + pixel;
  }

  if (variant == 9 || variant == 16 || variant == 17) {
    // SliceJulibrot2 and square multirot slices.
    return cx_mul(z, z) + pixel;
  }

  if (variant == 10 || variant == 18 || variant == 21) {
    // SliceJulibrot4 and power multirot slices.
    return cx_pow_real(z, max(0.25, abs(uSeedX))) + pixel;
  }

  if (variant == 11) {
    // SliceJulibrot5: (-z)^n + c.
    return cx_pow_real(-z, max(0.25, abs(uSeedX))) + pixel;
  }

  if (variant == 19 || variant == 20) {
    // NewDivideBrot / AllNewDivideBrot: z^2*fn1(z^a+b)+c,
    // optionally scaled by b.
    float aa = -(a - 2.0);
    float bb = b + 1e-8;
    vec2 core = cx_mul(cx_mul(z, z), fotdFn1(cx_pow_real(z, aa) + vec2(bb, 0.0)));
    if (variant == 20) {
      core *= bb;
    }
    return core + pixel;
  }

  if (variant == 22) {
    // JimsCompMand: z = z^p1 * c^p2 + c.
    return cx_mul(cx_pow_real(z, b), cx_pow_real(pixel, f)) + pixel;
  }

  if (variant == 24) {
    // MandNewt family: z = z - relax*h/j.
    vec2 h = cx_pow_real(z, max(1.0, abs(b))) + cx_mul(pixel - vec2(uCoeffD, 0.0), z) - vec2(uPowerF, 0.0);
    vec2 j = uCoeffJ * cx_pow_real(z, max(1.0, abs(uPowerK))) + pixel - vec2(1.0, 0.0);
    return z - uCoeffG * cx_div(h, j);
  }

  if (variant == 25) {
    // CrazyNewton: zx=z^b; zy=c*(zx*z); z=(d*zy+a)/(k*zx).
    vec2 zx = cx_pow_real(z, max(1.0, abs(b)));
    vec2 zy = uCoeffD * cx_mul(zx, z);
    return cx_div(uPowerF * zy + vec2(a, 0.0), max(abs(uCoeffG), 1e-4) * zx);
  }

  if (variant == 26) {
    // DivideBrot6: z^a/(z^(-b)+d)+c.
    vec2 denom = cx_pow_real(z, -b) + vec2(uCoeffD + 1e-8, 0.0);
    return cx_div(cx_pow_real(z, max(0.25, abs(a))), denom) + pixel;
  }

  if (variant == 28) {
    // MandelbrotMix: two weighted powers plus c, explicit seed.
    return a * cx_pow_real(z, b) + d * cx_pow_real(z, f) + pixel;
  }

  if (variant == 29) {
    // DivideBrot5Julia: rational dividebrot with fixed Julia c.
    float aa = a - 2.0;
    float bb = max(abs(b), 1e-8);
    vec2 denom = cx_pow_real(z, -aa) + vec2(bb, 0.0);
    return cx_div(cx_mul(z, z), denom) + vec2(uCoeffD, uPowerF);
  }

  if (variant == 30) {
    // FinalDivideBrot: -b*z^2*fn1(z^a+b)-c.
    float aa = -(a - 2.0);
    float bb = b + 1e-8;
    vec2 core = -bb * cx_mul(cx_mul(z, z), fotdFn1(cx_pow_real(z, aa) + vec2(bb, 0.0)));
    return core - pixel;
  }

  if (variant == 31) {
    // MultiExp: exponential escape family approximation.
    return cx_exp(cx_pow_real(z, max(1.0, abs(b)))) + pixel;
  }

  if (variant == 32) {
    // Fixed-constant Julia-style map used by main Legalize gallery formulas.
    return cx_mul(z, z) + vec2(uCoeffG, uPowerH);
  }

  // MandelbrotMix4 / MandAutoCritInZ / MandelbrotMix2:
  // z = k * (a*z^b + d*z^f) + c.
  return uCoeffG * (a * cx_pow_real(z, b) + d * cx_pow_real(z, f)) + pixel;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 pixel = uv / max(uZoom, 1e-6) + uCenter;

  int variant = int(floor(uVariant + 0.5));
  vec2 z;
  vec2 aux = vec2(uCoeffD, uPowerF);
  if (variant <= 2) {
    z = mixCriticalPoint(uCoeffA, uPowerB, uCoeffD, uPowerF);
    if (variant == 1) {
      z += vec2(uSeedX, uSeedY);
    }
  } else if (variant == 3) {
    z = vec2(uSeedX, uSeedY);
  } else if (variant == 4 || variant == 5) {
    z = vec2(uCoeffD, uPowerF);
  } else if (variant == 9 || variant == 10 || variant == 11 || variant == 15) {
    julibrotSlice(pixel, pixel, z);
  } else if (variant == 12) {
    z = vec2(uCoeffA, uPowerB);
    aux = vec2(uCoeffD, uPowerF);
  } else if (variant == 23) {
    aux = pixel;
    z = cx_pow_real(pixel, uCoeffA) + cx_pow_real(uPowerB * pixel, uCoeffD);
  } else if (variant == 24 || variant == 25 || variant == 29) {
    z = pixel;
  } else if (variant == 26 || variant == 30) {
    z = vec2(0.0);
  } else if (variant == 31 || variant == 32) {
    z = pixel;
  } else if (variant == 28) {
    z = vec2(uSeedX, uSeedY);
  } else if (variant == 16 || variant == 18) {
    float aa = radians(uCoeffA);
    float bb = radians(uPowerB);
    z = vec2(sin(bb) * pixel.x, sin(aa) * pixel.y) + vec2(uCoeffG, uPowerH);
    pixel = vec2(cos(bb) * pixel.x, cos(aa) * pixel.y) + vec2(uCoeffJ, uPowerK);
  } else if (variant == 17 || variant == 21) {
    vec2 d = vec2(cos(radians(uCoeffA)), sin(radians(uCoeffA)));
    vec2 f = vec2(cos(radians(uPowerB)), sin(radians(uPowerB)));
    z = f * pixel.x + vec2(uCoeffG, uPowerH);
    pixel = d * pixel.y + vec2(uCoeffJ, uPowerK);
  } else {
    z = pixel;
  }

  float bailoutSq = max(4.0, uBailout * uBailout);
  const int MAX_ITERS = 220;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int it = target;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) {
      break;
    }
    if (variant == 12) {
      vec2 q = cx_mul(z, z) - cx_mul(aux, aux) + pixel;
      aux = (uSeedX + 2.0) * cx_mul(z, aux) + vec2(uSeedY, 0.0);
      z = q;
    } else if (variant == 23) {
      z = cx_pow_real(fotdFn1(z) + uPowerF * aux, uCoeffG) +
          uPowerH * cx_cos(aux);
      aux = cx_mul(aux, aux);
    } else {
      z = fotdIterate(z, pixel, variant);
    }
    if (dot(z, z) + dot(aux, aux) > bailoutSq) {
      it = i;
      break;
    }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(dot(z, z), 1e-12);
  float smoothVal = float(it) - log2(max(log2(mag2), 1e-6)) + 4.0;
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
}
