#include <flutter/runtime_effect.glsl>

precision highp float;

// Split-complex (perplex number) Mandelbrot: z_{n+1} = z⊗z + c  where ⊗ is split-complex mul (j²=+1).
// sMul(a,b) = (a.x·b.x + a.y·b.y, a.x·b.y + a.y·b.x)
// Derivative d/dc: der_{n+1} = 2·sMul(z_n, der_n) + 1.
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

// Split-complex/perplex numbers: (x + yj), j² = +1
vec2 sMul(vec2 a, vec2 b) {
  return vec2(a.x * b.x + a.y * b.y, a.x * b.y + a.y * b.x);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = vec2(0.0);
  vec2 der = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }
    // d(sMul(z,z)+c)/dc = 2·sMul(z, der) + 1
    der = 2.0 * vec2(z.x * der.x + z.y * der.y, z.x * der.y + z.y * der.x) + vec2(1.0, 0.0);
    z = sMul(z, z) + c;
    if (dot(z, z) > bailoutSq) { it = i; break; }
    it = i + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
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
