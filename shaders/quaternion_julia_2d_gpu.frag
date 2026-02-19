#include <flutter/runtime_effect.glsl>

precision highp float;

// Quaternion Julia set (2D slice): q_{n+1} = q_n² + c_fixed.
// Derivative dq/dq₀ tracked via product rule (non-commutative):
//   qder_{n+1} = qMul(q_n, qder_n) + qMul(qder_n, q_n).
// Normal-map uses xy projection: z2 = q.xy, der = qder.xy.
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
  if (scheme == 0) {
    return vec3(0.5) + 0.5 * cos(6.28318 * (vec3(t) + vec3(0.0, 0.4, 0.7)));
  } else if (scheme == 1) {
    return vec3(0.5) + 0.5 * cos(6.28318 * (vec3(t) + vec3(0.5, 0.3, 0.0)));
  } else if (scheme == 2) {
    return vec3(0.5) + 0.5 * cos(6.28318 * (vec3(t) + vec3(0.0, 0.33, 0.67)));
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

vec4 qMul(vec4 a, vec4 b) {
  return vec4(
    a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w,
    a.x * b.y + a.y * b.x + a.z * b.w - a.w * b.z,
    a.x * b.z - a.y * b.w + a.z * b.x + a.w * b.y,
    a.x * b.w + a.y * b.z - a.z * b.y + a.w * b.x
  );
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  float zSlice = 0.25 * sin(uTime * 0.17);
  float wSlice = 0.25 * cos(uTime * 0.13);
  vec4 q = vec4(uv / max(0.000001, uZoom) + uCenter, zSlice, wSlice);
  vec4 c = vec4(-0.20, 0.74, 0.12, -0.08);
  // Julia: qder₀ = identity quaternion (dq₀/dq₀)
  vec4 qder = vec4(1.0, 0.0, 0.0, 0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    // Product rule for non-commutative qMul: d(q²)/dq₀ = q·qder + qder·q
    qder = qMul(q, qder) + qMul(qder, q);
    q = qMul(q, q) + c;
    if (dot(q, q) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(q, q));
  float smoothVal = float(it) - log2(log2(mag2));

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Project quaternion derivative to the 2D viewing plane (xy)
    vec2 z2  = q.xy;
    vec2 der = qder.xy;
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
