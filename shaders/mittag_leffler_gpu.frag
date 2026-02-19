#include <flutter/runtime_effect.glsl>

precision highp float;

// Mittag-Leffler Fractal: z_{n+1} = E_alpha(z^2) + c
// E_alpha(w) = sum_{k=0}^{N-1} w^k / Gamma(alpha*k + 1), N=15 terms
// Generalization of the exponential function (alpha=1 gives exp).
// Extra param: alpha at slot 10 (default 1.5)
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uAlpha;         // 10

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

vec2 cx_mul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

// Stirling approximation for Gamma function (real argument only)
// Used to compute 1/Gamma(alpha*k+1) for the ML series.
float gammaApprox(float x) {
  if (x <= 0.0) return 1e20;
  if (x < 1.0) {
    // Gamma(x) = Gamma(x+1)/x
    return gammaApprox(x + 1.0) / x;
  }
  // Stirling: Gamma(x) ~ sqrt(2*pi/x) * (x/e)^x
  float lnG = 0.5 * log(6.28318 / x) + x * (log(x) - 1.0);
  return exp(lnG);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  float alpha = uAlpha;
  vec2 z = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  // Precompute 1/Gamma(alpha*k+1) for k=0..14
  float invGamma[15];
  for (int k = 0; k < 15; k++) {
    invGamma[k] = 1.0 / gammaApprox(alpha * float(k) + 1.0);
  }

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    // w = z^2
    vec2 w = cx_mul(z, z);
    // E_alpha(w) = sum w^k / Gamma(alpha*k + 1)
    vec2 ea = vec2(invGamma[0], 0.0); // k=0: 1/Gamma(1) = 1
    vec2 wk = w; // w^1
    for (int k = 1; k < 15; k++) {
      ea += invGamma[k] * wk;
      wk = cx_mul(wk, w);
    }
    z = ea + c;
    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;

  if (schemeInt >= 50) {
    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    vec2 nv = normalize(z);
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);
    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) % 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
