#include <flutter/runtime_effect.glsl>

precision highp float;

// IMPORTANT: uniform ORDER matches julia_module.dart setFloat indices.
// Julia Set: z_{n+1} = z² + c, z₀ = pixel, c = (uJuliaReal, uJuliaImag) fixed.
// Derivative (dz/dz₀, Julia-style): der = 2z·der, der₀ = 1.
// colorScheme 10: point-trap (orbit distance to origin).
// colorScheme 11: cross-trap (orbit distance to axes).
// colorScheme 50-63: normal-map (bas-relief) — 14 light angles × 4 base palettes.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uJuliaReal;     // 9
uniform float uJuliaImag;     // 10
uniform float uTransparentBg; // 11

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
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

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;
  vec2 c = vec2(uJuliaReal, uJuliaImag);
  // Julia-style derivative dz/dz₀: der₀ = 1
  vec2 der = vec2(1.0, 0.0);

  float bailoutSq = uBailout * uBailout;
  int scheme = int(uColorScheme);

  const int MAX_ITERS = 320;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  float minDistSq = 1e9; // scheme 10: point trap at origin
  float crossDist = 1e9; // scheme 11: cross trap

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    // d(z²+c)/dz₀ = 2z·der  (c is constant, dc/dz₀=0)
    if (scheme >= 50) der = 2.0 * cmul(z, der);
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    float dSq = dot(z, z);
    minDistSq = min(minDistSq, dSq);
    crossDist = min(crossDist, min(abs(z.x), abs(z.y)));
    if (dSq > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (scheme == 10) {
    float d = clamp(sqrt(minDistSq) / uBailout, 0.0, 1.0);
    float t = fract(d * 3.0 + uTime * 0.0001);
    fragColor = vec4(linearToSRGB(palette(t, 0)), 1.0);
    return;
  }
  if (scheme == 11) {
    float d = clamp(crossDist * 4.0, 0.0, 1.0);
    float t = fract(d * 2.0 + uTime * 0.0001);
    fragColor = vec4(linearToSRGB(palette(t, 1)), 1.0);
    return;
  }

  if (it >= target) {
    float trapGlow = exp(-8.0 * sqrt(minDistSq)) + exp(-10.0 * crossDist);
    float t = fract(0.20 * trapGlow + 0.05 * atan(z.y, z.x) + uTime * 0.0001);
    vec3 color = palette(t, scheme) * (0.45 + 0.35 * clamp(trapGlow, 0.0, 1.0));
    fragColor = vec4(linearToSRGB(color), uTransparentBg > 0.5 ? 0.85 : 1.0);
    return;
  }

  float mag2      = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (scheme >= 50) {
    float angle   = float(scheme - 50) * (3.14159265 / 13.0);
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
    int basePal = (scheme - 50) - ((scheme - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  vec3 color = palette(t, scheme);
  fragColor = vec4(linearToSRGB(color), 1.0);
}
