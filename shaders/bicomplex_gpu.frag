#include <flutter/runtime_effect.glsl>

precision highp float;

// Bicomplex Mandelbrot: (z1,z2)_{n+1} = (z1²-z2²+c1, 2·z1·z2+c2), c2 animated.
// Derivative d/dc1: (der1,der2)_{n+1} = (2·cmul(z1,der1)-2·cmul(z2,der2)+1, 2·(cmul(z1,der2)+cmul(z2,der1))).
// Normal-map uses z1 and der1 (the c1-driven complex component).
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

// colorScheme 0-49: standard palette. 50-63: normal-map (14 angles × 4 palettes).
vec3 palette(float t, int scheme) {
  if (scheme == 0) return vec3(0.5) + 0.5 * cos(6.28318 * (vec3(t) + vec3(0.0, 0.4, 0.7)));
  if (scheme == 1) return vec3(0.5) + 0.5 * cos(6.28318 * (vec3(t) + vec3(0.5, 0.3, 0.0)));
  if (scheme == 2) return vec3(0.5) + 0.5 * cos(6.28318 * (vec3(t) + vec3(0.0, 0.33, 0.67)));
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

// Bicomplex as pair of complex numbers (z1, z2)
// (z1, z2) * (w1, w2) = (z1*w1 - z2*w2, z1*w2 + z2*w1)
void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c1 = uv / max(0.000001, uZoom) + uCenter;
  vec2 c2 = vec2(0.22 * cos(uTime * 0.07), 0.22 * sin(uTime * 0.11));

  vec2 z1 = vec2(0.0);
  vec2 z2 = vec2(0.0);
  // d(z1,z2)/dc1, Mandelbrot-style (z1₀=z2₀=0, c1=pixel)
  vec2 der1 = vec2(0.0);
  vec2 der2 = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }

    vec2 z1sq = cmul(z1, z1);
    vec2 z2sq = cmul(z2, z2);
    vec2 z1z2 = cmul(z1, z2);

    // d(z1_new)/dc1 = 2·cmul(z1,der1) - 2·cmul(z2,der2) + 1
    // d(z2_new)/dc1 = 2·(cmul(z1,der2) + cmul(z2,der1))
    vec2 nd1 = 2.0 * cmul(z1, der1) - 2.0 * cmul(z2, der2) + vec2(1.0, 0.0);
    vec2 nd2 = 2.0 * (cmul(z1, der2) + cmul(z2, der1));

    z1 = z1sq - z2sq + c1;
    z2 = 2.0 * z1z2 + c2;
    der1 = nd1;
    der2 = nd2;

    float magSq = dot(z1, z1) + dot(z2, z2);
    if (magSq > bailoutSq) { it = i; break; }
    it = i + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z1, z1) + dot(z2, z2));
  float smoothVal = float(it) - log2(log2(mag2 + 1.0));

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Use z1 and der1 (the viewable complex component)
    float denom = max(1e-12, dot(der1, der1));
    vec2 nv = vec2( z1.x * der1.x + z1.y * der1.y,
                    z1.y * der1.x - z1.x * der1.y) / denom;
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

  float phase = 0.12 * atan(z2.y, z2.x);
  float t = fract(smoothVal / 64.0 + phase + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
