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

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p = p * 2.0 + 0.5;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = int(clamp(float(target / 15 + 1), 1.0, 18.0));

  vec2 q = p;
  float keep = 1.0;
  float level = 0.0;
  float edge = 1e9;

  for (int i = 0; i < 18; i++) {
    if (i >= depth) break;

    vec2 f = fract(q);
    vec2 d = abs(f - 0.5);
    edge = min(edge, min(abs(d.x - 1.0 / 6.0), abs(d.y - 1.0 / 6.0)) / pow(3.0, float(i)));

    bool removedX = (f.x > 1.0 / 3.0 && f.x < 2.0 / 3.0);
    bool removedY = (f.y > 1.0 / 3.0 && f.y < 2.0 / 3.0);
    if (removedX || removedY) {
      keep = 0.0;
      level = float(i) / float(depth);
      break;
    }

    q *= 3.0;
    level = float(i + 1) / float(depth);
  }

  if (keep < 0.5) {
    if (uTransparentBg > 0.5) {
      fragColor = vec4(0.0);
    } else {
      float bgT = fract(0.18 * sin(17.0 * p.x + 11.0 * p.y) + 0.16 * length(p));
      vec3 bg = getPaletteColor(bgT, int(uColorScheme)) * 0.24;
      fragColor = vec4(linearToSRGB(bg), 1.0);
    }
    return;
  }

  float t = fract(level + 0.28 * exp(-24.0 * edge) + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.5 + 0.9 * smoothstep(0.2, 0.0, edge);

  fragColor = vec4(linearToSRGB(color), 1.0);
}
