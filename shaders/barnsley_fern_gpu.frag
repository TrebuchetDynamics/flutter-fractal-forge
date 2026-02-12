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

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p = p * vec2(6.0, 10.0) + vec2(0.0, 0.5);

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));

  vec2 q = p;
  float hit = 0.0;
  float depth = 0.0;
  float trap = 1e9;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    float l0 = length(q - vec2(0.0, 1.6));
    float l1 = length(q - vec2(0.0, 1.6));
    float l2 = length(q - vec2(-0.44, 1.6));
    float l3 = length(q - vec2(0.52, 0.44));

    vec2 c0 = vec2(0.0, 1e6);
    float inv0 = l0;
    float inv1 = l1;
    float inv2 = l2;
    float inv3 = l3;

    // inverse of f1: x'=0, y'=0.16y -> preimage near stem only
    if (abs(q.x) < 0.02) {
      c0 = vec2(0.0, q.y / 0.16);
      inv0 = length(c0);
    }

    // inverse of f2: [0.85 0.04; -0.04 0.85] * p + (0,1.6)
    vec2 r1 = q - vec2(0.0, 1.6);
    vec2 c1 = vec2(0.85 * r1.x - 0.04 * r1.y, 0.04 * r1.x + 0.85 * r1.y) / 0.7241;
    inv1 = length(c1);

    // inverse of f3: [0.2 -0.26; 0.23 0.22] * p + (0,1.6)
    vec2 r2 = q - vec2(0.0, 1.6);
    vec2 c2 = vec2(0.22 * r2.x + 0.26 * r2.y, -0.23 * r2.x + 0.2 * r2.y) / 0.1038;
    inv2 = length(c2);

    // inverse of f4: [-0.15 0.28; 0.26 0.24] * p + (0,0.44)
    vec2 r3 = q - vec2(0.0, 0.44);
    vec2 c3 = vec2(0.24 * r3.x - 0.28 * r3.y, -0.26 * r3.x - 0.15 * r3.y) / 0.1092;
    inv3 = length(c3);

    float best = inv1;
    q = c1;
    if (inv2 < best) { best = inv2; q = c2; }
    if (inv3 < best) { best = inv3; q = c3; }
    if (inv0 < best) { best = inv0; q = c0; }

    trap = min(trap, best / pow(1.18, float(i + 1)));

    if (best < 1.2) {
      hit = 1.0;
      depth = float(i + 1) / float(target);
      break;
    }
  }

  if (hit < 0.5) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(0.18 + depth + 0.25 * exp(-16.0 * trap) + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= vec3(0.6, 1.0, 0.7);
  fragColor = vec4(color, 1.0);
}
