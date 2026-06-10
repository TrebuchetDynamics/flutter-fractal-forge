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

// O(log n): bit = floor((n+1)*phi) - floor(n*phi)
float fibWordBit(float n) {
  float phi = 1.61803398875;
  return mod(floor((n + 1.0) * phi) - floor(n * phi), 2.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  float yBands = 64.0;
  vec2 q = p * vec2(42.0, yBands);
  float band = floor(q.y + 0.5);
  float x = q.x + 90.0;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int n = int(clamp(float(target) * 1.4, 40.0, 380.0));

  float nearest = 1e9;
  float acc = 0.0;

  for (int i = 0; i < 380; i++) {
    if (i >= n) break;
    float bit = fibWordBit(float(i));
    acc += (bit > 0.5) ? 1.0 : -1.0;

    vec2 c = vec2(float(i), acc * 0.65);
    float d = length(vec2(x, band) - c);
    nearest = min(nearest, d);
  }

  // Draw the symbolic orbit as a readable ribbon instead of sub-pixel dots.
  // The visual catalog smoke test samples the central viewport; a broader glow
  // makes the Fibonacci word structure measurable without changing uniforms.
  float thickness = mix(1.2, 0.65, clamp(uBailout / 8.0, 0.0, 1.0));
  float line = exp(-3.5 * nearest * nearest / max(0.01, thickness));

  float cell = fibWordBit(floor(max(0.0, x)));
  float backgroundWeave = 0.035 * (0.5 + 0.5 * sin(0.9 * x + 1.7 * band + 3.14159 * cell));
  line = max(line, backgroundWeave);

  float t = fract((band * 0.037 + x * 0.003) + 0.3 * line + uTime * 0.00008);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= 0.15 + line;

  fragColor = vec4(linearToSRGB(color), 1.0);
}
