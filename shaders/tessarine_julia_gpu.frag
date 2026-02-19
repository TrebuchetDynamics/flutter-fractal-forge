#include <flutter/runtime_effect.glsl>

precision highp float;

// Tessarine Julia set: z_{n+1} = tMul(z_n, z_n) + c_fixed.
// Tessarine t = a + bi + cj + dk, i²=-1, j²=+1, k=ij, commutative algebra.
// Derivative dz/dz₀ via commutative product rule:
//   tder_{n+1} = 2·tMul(z_n, tder_n).
// Normal-map uses xy projection: z2 = z.xy, der = tder.xy.
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

// Tessarine t = a + b i + c j + d k,
// with i² = -1, j² = 1, k = i j, k² = -1 (commutative algebra).
vec4 tMul(vec4 p, vec4 q) {
  float a = p.x * q.x - p.y * q.y + p.z * q.z - p.w * q.w;
  float b = p.x * q.y + p.y * q.x + p.z * q.w + p.w * q.z;
  float c = p.x * q.z + p.z * q.x - p.y * q.w - p.w * q.y;
  float d = p.x * q.w + p.w * q.x + p.y * q.z + p.z * q.y;
  return vec4(a, b, c, d);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  float jSlice = 0.18 * sin(uTime * 0.11);
  float kSlice = -0.21 * cos(uTime * 0.09);
  vec4 z = vec4(uv / max(0.000001, uZoom) + uCenter, jSlice, kSlice);
  vec4 c = vec4(-0.28, 0.62, 0.15, -0.12);
  // Julia: tder₀ = identity tessarine (dz₀/dz₀)
  vec4 tder = vec4(1.0, 0.0, 0.0, 0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int n = 0; n < MAX_ITERS; n++) {
    if (n >= target) { it = target; break; }
    // Commutative product rule: d(z²)/dz₀ = 2·tMul(z, tder)
    tder = 2.0 * tMul(z, tder);
    z = tMul(z, z) + c;
    if (dot(z, z) > bailoutSq) { it = n; break; }
    it = n + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Project tessarine derivative to the 2D viewing plane (xy)
    vec2 z2  = z.xy;
    vec2 der = tder.xy;
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z2.x * der.x + z2.y * der.y,
                    z2.y * der.x - z2.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

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
