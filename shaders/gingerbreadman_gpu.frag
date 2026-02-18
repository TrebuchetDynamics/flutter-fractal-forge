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

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 palette(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.20, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.8, 0.6), vec3(0.00, 0.10, 0.20));
  if (scheme == 3) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0));

  float s = float(scheme);
  vec3 a = 0.5 + 0.2 * sin(vec3(1.0, 1.3, 1.7) * (0.17 * s + 0.1));
  vec3 b = 0.5 + 0.3 * cos(vec3(0.7, 1.1, 1.5) * (0.13 * s + 0.2));
  vec3 c = 1.0 + 0.7 * sin(vec3(0.9, 1.2, 1.6) * (0.11 * s + 0.3));
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

  float bailoutSq = uBailout * uBailout;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;

    float nx = 1.0 - y + abs(x);
    float ny = x;
    x = nx;
    y = ny;

    float r2 = x * x + y * y;
    if (r2 > bailoutSq) { it = j + 1; break; }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float r2 = max(1e-12, x * x + y * y);
  float smoothVal = float(it) - log2(log2(r2));
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);

  fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
}
