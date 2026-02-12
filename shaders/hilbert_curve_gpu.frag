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
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p = p * 1.8;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = clamp(int(floor(log2(float(target + 1)))), 1, 12);

  float gridF = exp2(float(depth));
  vec2 g = (p + 0.5) * gridF;
  vec2 cell = floor(g);

  float onCurve = 1.0;
  float level = float(depth);

  for (int i = 0; i < 12; i++) {
    if (i >= depth) break;

    vec2 local = fract(g) - 0.5;

    int div = 1 << (depth - i - 1);
    float bx = mod(floor(cell.x / float(max(div, 1))), 2.0);
    float by = mod(floor(cell.y / float(max(div, 1))), 2.0);

    float quad = bx + 2.0 * by;
    float d = max(abs(local.x), abs(local.y));

    if (quad < 1.0) {
      d = abs(local.x + local.y);
    } else if (quad < 2.0) {
      d = abs(local.y - local.x);
    } else if (quad < 3.0) {
      d = abs(local.x + local.y);
    } else {
      d = abs(local.y - local.x);
    }

    float thickness = 0.18 / exp2(float(i) * 0.5);
    if (d > thickness) {
      onCurve = 0.0;
      level = float(i);
      break;
    }

    g *= 2.0;
  }

  if (onCurve < 0.5) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(level / float(max(depth, 1)) + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.6 + 0.5 * (level / float(max(depth, 1)));
  fragColor = vec4(color, 1.0);
}
