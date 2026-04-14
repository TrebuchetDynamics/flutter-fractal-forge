#include <flutter/runtime_effect.glsl>

precision highp float;

// Kaleidoscope: 3 mirrors in triangle = hexagonal reflections
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

vec2 rotate(vec2 p, float a) {
  float c = cos(a), s = sin(a);
  return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

// 3 mirrors at 60° apart forming equilateral triangle
// Creates 6-fold hexagonal symmetry
vec2 kaleidoscope3Mirror(vec2 uv, float time) {
  float PI = 3.14159265359;
  float angle60 = PI / 3.0;  // 60 degrees
  
  // Rotate the whole system
  uv = rotate(uv, time * 0.4);
  
  // Apply 3 mirror reflections
  for (int i = 0; i < 3; i++) {
    float mirrorAngle = float(i) * angle60;
    
    // Mirror normal direction (perpendicular to mirror line)
    float normalAngle = mirrorAngle + PI / 2.0;
    vec2 normal = vec2(cos(normalAngle), sin(normalAngle));
    
    // Reflect if point is on wrong side
    float d = dot(uv, normal);
    if (d > 0.0) {
      uv = uv - 2.0 * normal * d;
    }
  }
  
  return uv;
}

// Create objects that get reflected
float glassPieces(vec2 p, float time) {
  float v = 0.0;
  
  // Main colored glass pieces
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float angle = fi * 2.094 + time * 0.5;  // 120° apart
    float radius = 0.18 + sin(time + fi) * 0.03;
    vec2 pos = vec2(cos(angle), sin(angle)) * radius;
    float size = 0.1 + sin(time * 1.5 + fi) * 0.02;
    v += smoothstep(size, size * 0.1, length(p - pos));
  }
  
  // Smaller fragments
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    vec2 pos = vec2(
      sin(time * 0.6 + fi * 1.1) * 0.35,
      cos(time * 0.5 + fi * 0.9) * 0.35
    );
    v += smoothstep(0.04, 0.01, length(p - pos)) * 0.6;
  }
  
  return clamp(v, 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float screenScale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, screenScale);
  uv /= max(0.000001, uZoom);
  uv += uCenter;
  
  // Apply 3-mirror kaleidoscope (triangle = hexagonal)
  vec2 kal = kaleidoscope3Mirror(uv, uTime);
  
  float pat = glassPieces(kal, uTime);
  
  int scheme = int(mod(uColorScheme, 16.0));
  vec3 col = palette(pat + uTime * 0.1, scheme);
  
  if (uTransparentBg > 0.5) {
    fragColor = vec4(col, pat);
  } else {
    fragColor = vec4(col, 1.0);
  }
}
