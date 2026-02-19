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


float rotSlice(vec3 p) {
  float a = 0.5 + 0.2 * sin(0.11 * uTime);
  float ca = cos(a), sa = sin(a);
  mat2 r = mat2(ca, -sa, sa, ca);
  p.xz = r * p.xz;
  p.yz = r * p.yz;
  return p.z;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p2 = (uv / max(0.000001, uZoom) + uCenter) * 2.0;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = clamp(target / 20 + 1, 1, 8);

  vec3 p = vec3(p2, 0.0);
  float hole = 0.0;
  float level = 0.0;

  for (int i = 0; i < 8; i++) {
    if (i >= depth) break;
    vec3 q = p * pow(3.0, float(i));
    q = abs(fract(q + 0.5) - 0.5);
    int bands = 0;
    if (q.x < 1.0 / 6.0) bands++;
    if (q.y < 1.0 / 6.0) bands++;
    if (q.z < 1.0 / 6.0) bands++;
    if (bands >= 2) {
      hole = 1.0;
      level = float(i + 1) / float(depth);
      break;
    }
    p.z = rotSlice(vec3(p.xy, p.z));
  }

  if (hole < 0.5) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(level + 0.13 * sin(7.0 * p2.x + 5.0 * p2.y) + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
}
