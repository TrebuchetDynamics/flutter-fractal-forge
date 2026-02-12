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

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b * cos(6.28318 * (c * t + d)); }
vec3 getPaletteColor(float t, int s) {
  t = fract(t);
  if (s == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (s == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.00, 0.15, 0.20));
  if (s == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));
  float fs = float(s);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37 * fs + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29 * fs + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11 * fs + 0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (fs + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 mobiusDisk(vec2 z, vec2 a) {
  float az2 = dot(a, a);
  vec2 num = z + a;
  vec2 den = vec2(1.0 + dot(a, z), a.x * z.y - a.y * z.x);
  float inv = 1.0 / max(1e-6, dot(den, den));
  return vec2((num.x * den.x + num.y * den.y), (num.y * den.x - num.x * den.y)) * inv;
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fc - 0.5 * uResolution) / max(1.0, scale);
  vec2 z = uv / max(0.000001, uZoom) + uCenter;
  z *= 1.8;

  float r = length(z);
  if (r >= 0.999) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  int depth = int(clamp(2.0 + 0.08 * uIterations, 2.0, 24.0));
  float best = 1e9;
  float word = 0.0;
  vec2 p = z;

  for (int i = 0; i < 24; i++) {
    if (i >= depth) break;

    float d1 = abs(dot(normalize(vec2(1.0, 0.3)), p));
    float d2 = abs(dot(normalize(vec2(-0.4, 1.0)), p));
    best = min(best, min(d1, d2) * (1.0 - dot(p, p)));

    vec2 a = (mod(float(i), 2.0) < 0.5) ? vec2(0.42, 0.0) : vec2(0.0, 0.42);
    if (mod(floor(float(i) * 0.5), 2.0) > 0.5) a = -a;

    p = mobiusDisk(p, a);
    word += length(a) * exp(-0.22 * float(i));
  }

  float boundary = exp(-130.0 * abs(1.0 - r));
  float edge = exp(-220.0 * best);
  float vis = max(edge, boundary * 0.35);

  if (vis < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float t = fract(0.35 * word + 0.25 * edge + uTime * 0.00008);
  vec3 col = getPaletteColor(t, int(uColorScheme));
  col *= mix(0.2, 1.15, vis);
  fragColor = vec4(col, (uTransparentBg > 0.5) ? vis : 1.0);
}
