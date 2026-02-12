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

vec4 qMul(vec4 a, vec4 b) {
  return vec4(
    a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w,
    a.x * b.y + a.y * b.x + a.z * b.w - a.w * b.z,
    a.x * b.z - a.y * b.w + a.z * b.x + a.w * b.y,
    a.x * b.w + a.y * b.z - a.z * b.y + a.w * b.x
  );
}

vec4 qConj(vec4 q) {
  return vec4(q.x, -q.y, -q.z, -q.w);
}

vec4 qInv(vec4 q) {
  float n2 = dot(q, q);
  if (n2 < 1e-20) return vec4(1e10, 0.0, 0.0, 0.0);
  return qConj(q) / n2;
}

float d2(vec4 a, vec4 b) {
  vec4 d = a - b;
  return dot(d, d);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  float zSlice = 0.2 * sin(uTime * 0.09);
  float wSlice = -0.2 * cos(uTime * 0.12);
  vec4 q = vec4(uv / max(0.000001, uZoom) + uCenter, zSlice, wSlice);

  float escapeSq = max(16.0, uBailout * uBailout);
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }

    vec4 q2 = qMul(q, q);
    vec4 q3 = qMul(q2, q);

    vec4 f = q3 - vec4(1.0, 0.0, 0.0, 0.0);
    vec4 fp = 3.0 * q2;

    vec4 step = qMul(f, qInv(fp));
    q = q - step;

    if (dot(step, step) < 1e-14) { it = i; break; }
    if (dot(q, q) > escapeSq) { it = i; break; }
    it = i + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec4 r0 = vec4(1.0, 0.0, 0.0, 0.0);
  vec4 r1 = vec4(-0.5, 0.8660254, 0.0, 0.0);
  vec4 r2 = vec4(-0.5, -0.8660254, 0.0, 0.0);
  float dd0 = d2(q, r0);
  float dd1 = d2(q, r1);
  float dd2 = d2(q, r2);

  float rootPhase = 0.0;
  if (dd1 < dd0 && dd1 < dd2) rootPhase = 0.3333333;
  else if (dd2 < dd0 && dd2 < dd1) rootPhase = 0.6666667;

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + 0.1 * q.z + uTime * 0.0001);
  fragColor = vec4(palette(t, int(uColorScheme)), 1.0);
}
