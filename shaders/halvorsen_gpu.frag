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
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  float x = p.x;
  float y = p.y;
  float z = 0.16 * cos(0.001 * uTime + p.x * 1.6 + p.y * 1.4);

  const float a = 1.4;
  const float dt = 0.007;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailoutSq = max(16.0, uBailout * uBailout);

  int it = target;
  float orbit = 0.0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    float dx = -a * x - 4.0 * y - 4.0 * z - y * y;
    float dy = -a * y - 4.0 * z - 4.0 * x - z * z;
    float dz = -a * z - 4.0 * x - 4.0 * y - x * x;

    x += dt * dx;
    y += dt * dy;
    z += dt * dz;

    float r2 = x * x + y * y + 0.1 * z * z;
    orbit += exp(-0.16 * (x * x + y * y)) + 0.08 * exp(-0.6 * abs(z));
    if (r2 > bailoutSq) {
      it = i + 1;
      break;
    }
  }

  if (it >= target) {
    float t = fract((orbit / float(target)) * 2.1 + 0.06 * atan(y, x) + uTime * 0.00005);
    vec3 col = getPaletteColor(t, int(uColorScheme));
    fragColor = vec4(col, uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float r2 = max(1e-10, x * x + y * y + z * z);
  float smoothVal = float(it) - log2(log2(r2 + 1.0));
  float t = fract(smoothVal / float(target) + uTime * 0.0001);
  fragColor = vec4(getPaletteColor(t, int(uColorScheme)), 1.0);
}
