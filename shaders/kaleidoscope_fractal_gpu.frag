#include <flutter/runtime_effect.glsl>

precision highp float;

// Kaleidoscope Fractal: 3 mirrors in triangle
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 palette(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.4)), 0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  if (scheme == 1) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)), 0.5 + 0.5 * cos(6.28318 * (t + 0.3)), 0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  if (scheme == 2) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.33)), 0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c4 = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c4 * t + d)), 0.0, 1.0);
}

vec2 rotate(vec2 p, float a) { float c = cos(a), s = sin(a); return vec2(p.x * c - p.y * s, p.x * s + p.y * c); }

vec2 kaleidoscope3Mirror(vec2 uv, float time) {
  uv = rotate(uv, time * 0.4);
  float angle60 = 1.0472;
  for (int i = 0; i < 3; i++) {
    float mirrorAngle = float(i) * angle60;
    vec2 normal = vec2(cos(mirrorAngle + 1.5708), sin(mirrorAngle + 1.5708));
    float d = dot(uv, normal);
    if (d > 0.0) uv = uv - 2.0 * normal * d;
  }
  return uv;
}

float fractalPattern(vec2 p, float time) {
  vec2 z = p;
  float v = 0.0;
  for (int i = 0; i < 6; i++) {
    z = abs(z);
    z = z * 1.5 - 0.5;
    z = rotate(z, 1.0472);
    v += exp(-length(z) * 2.0);
  }
  return clamp(v / 6.0, 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  uv /= max(0.000001, uZoom);
  uv += uCenter;
  
  vec2 kal = kaleidoscope3Mirror(uv, uTime);
  float pat = fractalPattern(kal, uTime);
  
  int scheme = int(mod(uColorScheme, 16.0));
  vec3 col = palette(pat + uTime * 0.08, scheme);
  
  if (uTransparentBg > 0.5) fragColor = vec4(col, pat);
  else fragColor = vec4(col, 1.0);
}
