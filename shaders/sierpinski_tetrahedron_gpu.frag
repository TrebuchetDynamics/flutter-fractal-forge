#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

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

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b,b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}


void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = (uv / max(0.000001, uZoom) + uCenter) * 2.0;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = clamp(target / 24 + 1, 1, 12);

  vec2 v0 = vec2(0.0, 0.78);
  vec2 v1 = vec2(-0.9, -0.52);
  vec2 v2 = vec2(0.9, -0.52);
  vec2 v3 = vec2(0.0, -0.1);

  float dMin = 1e9;
  float level = 0.0;
  vec2 q = p;
  for (int i = 0; i < 12; i++) {
    if (i >= depth) break;
    float d0 = dot(q - v0, q - v0);
    float d1 = dot(q - v1, q - v1);
    float d2 = dot(q - v2, q - v2);
    float d3 = dot(q - v3, q - v3);
    vec2 nearest = v0;
    dMin = d0;
    if (d1 < dMin) { dMin = d1; nearest = v1; }
    if (d2 < dMin) { dMin = d2; nearest = v2; }
    if (d3 < dMin) { dMin = d3; nearest = v3; }
    q = (q + nearest) * 2.0 - nearest;
    level = float(i + 1) / float(depth);
  }

  float trap = exp(-8.0 * sqrt(dMin));
  if (trap < 0.015) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(level + 0.45 * trap + uTime * 0.0001);
  vec3 color = palette(t, int(uColorScheme));
  fragColor = vec4(color * (0.7 + 0.6 * trap), 1.0);
}
