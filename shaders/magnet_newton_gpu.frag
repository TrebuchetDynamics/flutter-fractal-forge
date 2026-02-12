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

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318530718 * (c * t + d));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) return clamp(iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.15, 0.25)), 0.0, 1.0);
  if (scheme == 1) return clamp(iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.35, 0.20, 0.10)), 0.0, 1.0);
  if (scheme == 2) return clamp(iqPalette(t, vec3(0.55), vec3(0.45), vec3(1.0), vec3(0.10, 0.30, 0.40)), 0.0, 1.0);
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 d = fract(sin(vec3(13.7, 71.1, 43.3) * (s + 0.8)) * 32768.123);
  return clamp(iqPalette(t, vec3(0.52), vec3(0.48), vec3(1.0), d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cdivSafe(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-20);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

float rootDistanceSq(vec2 z, vec2 root) {
  vec2 d = z - root;
  return dot(d, d);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;
  float escapeSq = max(16.0, uBailout * uBailout);

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Magnet-Newton style rational: m(z)=(z^2-1)/(2z+1), then Newton on m(z)^3-1.
    vec2 z2 = cmul(z, z);
    vec2 m = cdivSafe(z2 - vec2(1.0, 0.0), 2.0 * z + vec2(1.0, 0.0));

    vec2 m2 = cmul(m, m);
    vec2 m3 = cmul(m2, m);
    vec2 f = m3 - vec2(1.0, 0.0);

    vec2 den = 2.0 * z + vec2(1.0, 0.0);
    vec2 numPrime = 2.0 * den - 2.0 * (z2 - vec2(1.0, 0.0)); // derivative numerator over den^2
    vec2 mPrime = cdivSafe(numPrime, cmul(den, den));

    vec2 fp = 3.0 * cmul(m2, mPrime);
    vec2 step = cdivSafe(f, fp);

    z = z - step;

    if (dot(step, step) < 1e-13) { it = j; break; }
    if (dot(z, z) > escapeSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec2 r0 = vec2(1.0, 0.0);
  vec2 r1 = vec2(-0.5, 0.86602540378);
  vec2 r2 = vec2(-0.5, -0.86602540378);

  vec2 z2f = cmul(z, z);
  vec2 m = cdivSafe(z2f - vec2(1.0, 0.0), 2.0 * z + vec2(1.0, 0.0));
  float d0 = rootDistanceSq(m, r0);
  float d1 = rootDistanceSq(m, r1);
  float d2 = rootDistanceSq(m, r2);

  float rootPhase = 0.0;
  if (d1 < d0 && d1 < d2) rootPhase = 0.3333333;
  else if (d2 < d0 && d2 < d1) rootPhase = 0.6666667;

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime * 0.0001);
  fragColor = vec4(palette(t, int(uColorScheme)), 1.0);
}
