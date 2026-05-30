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

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318530718 * (c * t + d));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) return clamp(iqPalette(t, vec3(0.50), vec3(0.50), vec3(1.0), vec3(0.00, 0.20, 0.40)), 0.0, 1.0);
  if (scheme == 1) return clamp(iqPalette(t, vec3(0.50), vec3(0.50), vec3(1.0), vec3(0.28, 0.16, 0.04)), 0.0, 1.0);
  if (scheme == 2) return clamp(iqPalette(t, vec3(0.55), vec3(0.45), vec3(1.0), vec3(0.10, 0.30, 0.55)), 0.0, 1.0);
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 d = fract(sin(vec3(9.7, 51.3, 73.9) * (s + 0.9)) * 34567.1);
  return clamp(iqPalette(t, vec3(0.52), vec3(0.48), vec3(1.0), d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cdivSafe(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-20);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

vec2 ccos(vec2 z) {
  float x = z.x;
  float y = z.y;
  return vec2(cos(x) * cosh(y), -sin(x) * sinh(y));
}

vec2 csin(vec2 z) {
  float x = z.x;
  float y = z.y;
  return vec2(sin(x) * cosh(y), cos(x) * sinh(y));
}

vec2 csec(vec2 z) {
  return cdivSafe(vec2(1.0, 0.0), ccos(z));
}

vec2 ccsc(vec2 z) {
  return cdivSafe(vec2(1.0, 0.0), csin(z));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = c;
  float escapeSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 nxt = (mod(float(j), 2.0) < 1.0) ? cmul(c, csec(z)) : cmul(c, ccsc(z));
    z = nxt;

    float r2 = dot(z, z);
    if (r2 > escapeSq || r2 != r2) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float ang = atan(z.y, z.x) / 6.28318530718 + 0.5;
  float t = fract(float(it) / max(1.0, uIterations) + 0.35 * ang + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
}
