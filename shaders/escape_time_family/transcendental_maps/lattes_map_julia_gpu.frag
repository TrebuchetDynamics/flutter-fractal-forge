#include <flutter/runtime_effect.glsl>

precision highp float;

// Lattes rational-map Julia set.
// R(z) = ((z^2 + 1)^2) / (4 z (z^2 - 1)).
// Poles at z = 0, ±1 are guarded so the shader remains finite.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.4)), 0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  if (scheme == 1) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)), 0.5 + 0.5 * cos(6.28318 * (t + 0.3)), 0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  if (scheme == 2) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.33)), 0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
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

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }

vec2 cdivSafe(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-20);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

float poleDistance(vec2 z) {
  return min(length(z), min(length(z - vec2(1.0, 0.0)), length(z + vec2(1.0, 0.0))));
}

vec2 lattesMap(vec2 z) {
  vec2 z2 = cmul(z, z);
  vec2 num = cmul(z2 + vec2(1.0, 0.0), z2 + vec2(1.0, 0.0));
  vec2 den = 4.0 * cmul(z, z2 - vec2(1.0, 0.0));
  return cdivSafe(num, den);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(uZoom, 1e-6) + uCenter;
  float bailoutSq = max(16.0, uBailout * uBailout);
  float trap = poleDistance(z);

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int it = target;
  bool escaped = false;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;
    float p = poleDistance(z);
    trap = min(trap, p);
    if (p < 1e-5) { it = j; escaped = true; break; }

    z = lattesMap(z);
    if (dot(z, z) > bailoutSq) { it = j; escaped = true; break; }
  }

  float boundary = exp(-18.0 * trap);
  float t = escaped
      ? fract(float(it) / float(target) + boundary + uTime * 0.0001)
      : fract(0.25 + boundary + 0.05 * log(1.0 + dot(z, z)) + uTime * 0.0001);
  vec3 color = palette(t, int(uColorScheme));
  if (!escaped) color *= 0.35 + 0.65 * boundary;

  if (length(color) < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }
  fragColor = vec4(linearToSRGB(color), 1.0);
}
