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

vec2 pentagonVertex(int i) {
  float a = (float(i) / 5.0) * 6.28318530718 + PI * 0.5;
  return vec2(cos(a), sin(a));
}

float sdRegularPentagon(vec2 p, float r) {
  float d = -1e9;
  for (int i = 0; i < 5; i++) {
    vec2 a = pentagonVertex(i);
    int nextIndex = (i + 1) - ((i + 1) / 5) * 5;
    vec2 b = pentagonVertex(nextIndex);
    vec2 edge = b - a;
    vec2 n = normalize(vec2(-edge.y, edge.x));
    d = max(d, dot(p / r - a, n));
  }
  return d * r;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p *= 1.9;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int depth = int(clamp(float(target / 18 + 1), 1.0, 16.0));

  float keep = 1.0;
  float score = 0.0;
  float trap = 1e9;
  vec2 z = p;

  for (int i = 0; i < 16; i++) {
    if (i >= depth) break;

    float minDist = 1e9;
    vec2 nearest = vec2(0.0);
    for (int k = 0; k < 5; k++) {
      vec2 v = pentagonVertex(k);
      float d = length(z - v);
      if (d < minDist) {
        minDist = d;
        nearest = v;
      }
    }

    trap = min(trap, minDist / pow(2.618, float(i)));
    z = (z - nearest) * 2.618;

    float inside = step(sdRegularPentagon(z, 1.0), 0.0);
    if (inside < 0.5) {
      keep = 0.0;
      score = float(i) / float(depth);
      break;
    }

    score = float(i + 1) / float(depth);
  }

  if (keep < 0.5) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(score + 0.35 * exp(-12.0 * trap) + uTime * 0.0001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.55 + 0.85 * smoothstep(0.22, 0.0, trap);
  fragColor = vec4(linearToSRGB(color), 1.0);
}
