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

  vec2 c1 = uv / max(0.000001, uZoom) + uCenter;
  vec2 c2 = vec2(0.22 * cos(uTime * 0.07), 0.22 * sin(uTime * 0.11));

  vec2 z1 = vec2(0.0);
  vec2 z2 = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }

    vec2 z1sq = cmul(z1, z1);
    vec2 z2sq = cmul(z2, z2);
    vec2 z1z2 = cmul(z1, z2);

    z1 = z1sq - z2sq + c1;
    z2 = 2.0 * z1z2 + c2;

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
  float phase = 0.12 * atan(z2.y, z2.x);
  float t = fract(smoothVal / 64.0 + phase + uTime * 0.0001);
  fragColor = vec4(palette(t, int(uColorScheme)), 1.0);
}
