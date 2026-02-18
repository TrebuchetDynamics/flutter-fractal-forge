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

mat2 rot(float a) {
  float c = cos(a), s = sin(a);
  return mat2(c, -s, s, c);
}

float triSDF(vec2 p) {
  // Right triangle with corners (0,0), (1,0), (0,0.5)
  float d0 = max(-p.x, -p.y);
  float d1 = p.x + 2.0 * p.y - 1.0;
  float d2 = p.y - 0.5;
  return max(max(d0, d1), d2);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p = p * 2.5 + vec2(0.6, 0.25);

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = clamp(target / 22 + 2, 2, 16);

  vec2 q = p;
  float d = 1e9;
  float level = 0.0;

  for (int i = 0; i < 16; i++) {
    if (i >= depth) break;

    q = abs(q);
    if (q.x + 2.0 * q.y > 1.0) {
      q = vec2(1.0 - q.x, 0.5 - q.y);
    }

    float td = abs(triSDF(q));
    d = min(d, td / pow(1.3, float(i)));

    q = rot(0.463647609) * q; // atan(1/2), pinwheel angle
    q = q * 1.5 - vec2(0.35, 0.15);
    level = float(i);
  }

  float edge = exp(-30.0 * d);
  if (edge < 0.04) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(level / float(max(depth, 1)) + 0.25 * edge + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.45 + 0.9 * edge;

  fragColor = vec4(linearToSRGB(color), 1.0);
}
