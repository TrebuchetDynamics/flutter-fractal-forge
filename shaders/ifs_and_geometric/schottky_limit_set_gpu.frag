#include <flutter/runtime_effect.glsl>

precision highp float;

// Schottky-style circle-inversion limit set approximation.
// Uses four disjoint inversion circles as a lightweight Kleinian/Schottky
// family representative for the catalog expansion research pass.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

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
    return 0.5 + 0.5 * cos(6.28318 * (vec3(0.0, 0.36, 0.68) + t));
  }
  if (scheme == 1) {
    return vec3(t * t, 0.35 + 0.65 * t, 1.0 - 0.45 * t);
  }
  float s = float(scheme);
  vec3 a = 0.52 + 0.18 * sin(vec3(1.0, 2.0, 3.0) * (0.21 * s + 0.3));
  vec3 b = 0.42 + 0.24 * cos(vec3(1.5, 2.1, 2.7) * (0.17 * s + 0.2));
  vec3 c = 0.9 + 0.7 * sin(vec3(0.7, 1.2, 1.8) * (0.13 * s + 0.4));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 1.0)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

float circleTrap(vec2 p, vec2 center, float radius) {
  return abs(length(p - center) - radius);
}

vec2 invertCircle(vec2 p, vec2 center, float radius) {
  vec2 q = p - center;
  float d = max(dot(q, q), 1e-6);
  return center + q * (radius * radius / d);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(uZoom, 1e-6) * 4.0 + uCenter;

  const vec2 c0 = vec2(-1.15, 0.0);
  const vec2 c1 = vec2( 1.15, 0.0);
  const vec2 c2 = vec2( 0.0,-1.15);
  const vec2 c3 = vec2( 0.0, 1.15);
  const float r = 0.72;

  float trap = 10.0;
  float hits = 0.0;
  int target = int(clamp(uIterations, 1.0, 160.0));

  for (int i = 0; i < 160; i++) {
    if (i >= target) break;

    float d0 = circleTrap(p, c0, r);
    float d1 = circleTrap(p, c1, r);
    float d2 = circleTrap(p, c2, r);
    float d3 = circleTrap(p, c3, r);
    trap = min(trap, min(min(d0, d1), min(d2, d3)));

    bool moved = false;
    if (length(p - c0) < r) { p = invertCircle(p, c0, r); moved = true; hits += 1.0; }
    if (length(p - c1) < r) { p = invertCircle(p, c1, r); moved = true; hits += 1.0; }
    if (length(p - c2) < r) { p = invertCircle(p, c2, r); moved = true; hits += 1.0; }
    if (length(p - c3) < r) { p = invertCircle(p, c3, r); moved = true; hits += 1.0; }
    if (!moved) {
      p = 0.985 * p + 0.015 * vec2(sin(uTime * 0.11), cos(uTime * 0.09));
    }
  }

  float line = exp(-70.0 * trap);
  float glow = exp(-9.0 * trap);
  float t = fract(0.08 * hits + glow + uTime * 0.00008);
  vec3 col = palette(t, int(uColorScheme));
  col = col * (0.18 + 0.82 * glow) + vec3(1.0, 0.92, 0.75) * line;

  float alpha = clamp(max(line, glow * 0.85), 0.0, 1.0);
  if (uTransparentBg > 0.5 && alpha < 0.02) {
    fragColor = vec4(0.0);
    return;
  }
  fragColor = vec4(linearToSRGB(col), 1.0);
}
