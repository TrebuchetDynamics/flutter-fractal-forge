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

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) return mix(vec3(0.04, 0.05, 0.07), vec3(0.9, 0.95, 0.85), t);
  float s = float(scheme);
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, vec3(0.52), vec3(0.48), vec3(1.0, 0.8, 0.6), d), 0.0, 1.0);
}

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float smoothCell(vec2 p, float v) {
  vec2 f = abs(fract(p) - 0.5);
  float cell = 1.0 - smoothstep(0.42, 0.50, max(float(f.x), float(f.y)));
  return v * cell;
}


// Seeds cellular automaton (B2/S): expanding birth-only fronts from sparse seeds.
void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(float(uResolution.x), float(uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(scale, 1.0);
  vec2 p = uv / max(uZoom, 0.000001) + uCenter;
  vec2 g = floor(p * 72.0);
  float steps = clamp(uIterations, 1.0, 500.0);

  float nearest = 999.0;
  float seedPhase = 0.0;
  for (int y = -2; y <= 2; y++) {
    for (int x = -2; x <= 2; x++) {
      vec2 q = g + vec2(float(x), float(y));
      float h = hash21(floor(q / 6.0));
      vec2 seed = floor(q / 6.0) * 6.0 + floor(vec2(hash21(q + 3.1), hash21(q + 8.7)) * 6.0);
      float d = length(g - seed);
      if (h > 0.72 && d < nearest) {
        nearest = d;
        seedPhase = h;
      }
    }
  }

  float wave = abs(nearest - mod(steps * 0.13 + seedPhase * 12.0, 18.0));
  float alive = smoothstep(1.3, 0.0, wave);
  alive += 0.35 * smoothstep(0.18, 0.0, abs(fract(nearest * 0.5 - steps * 0.05) - 0.5));
  alive = clamp(alive, 0.0, 1.0);

  if (alive < 0.05 && uTransparentBg > 0.5) { fragColor = vec4(0.0); return; }
  vec3 bg = vec3(0.015, 0.018, 0.028);
  vec3 col = getPaletteColor(seedPhase + nearest * 0.035 + steps * 0.002, int(uColorScheme));
  fragColor = vec4(linearToSRGB(mix(bg, col, smoothCell(p * 72.0, alive))), 1.0);
}
