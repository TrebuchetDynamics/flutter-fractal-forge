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
const float PI = 3.14159265359;

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

vec2 hexCenter(int i) {
  if (i == 0) return vec2(0.0);
  float a = (float(i - 1) / 6.0) * 6.28318530718;
  return vec2(cos(a), sin(a));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p *= 2.0;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = int(clamp(float(target / 18 + 1), 1.0, 14.0));

  vec2 z = p;
  float keep = 1.0;
  float level = 0.0;
  float trap = 1e9;

  for (int i = 0; i < 14; i++) {
    if (i >= depth) break;

    float best = 1e9;
    vec2 nearest = vec2(0.0);
    for (int k = 0; k < 7; k++) {
      vec2 c = hexCenter(k);
      float d = length(z - c);
      if (d < best) {
        best = d;
        nearest = c;
      }
    }

    trap = min(trap, best / pow(3.0, float(i) * 0.85));

    // Remove middle of ring between center and branches (hexaflake holes)
    float r = length(z);
    if (r > 0.33 && r < 0.66 && abs(atan(z.y, z.x)) < PI) {
      keep *= 1.0;
    }

    z = (z - nearest) * 3.0;

    vec2 a = abs(z);
    if (a.x > 1.2 || a.y > 1.2) {
      keep = 0.0;
      level = float(i) / float(depth);
      break;
    }

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

  float t = fract(level + 0.3 * exp(-10.0 * trap) + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.5 + 0.9 * smoothstep(0.3, 0.0, trap);
  fragColor = vec4(linearToSRGB(color), 1.0);
}
