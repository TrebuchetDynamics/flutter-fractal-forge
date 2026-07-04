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
uniform float uRoughness;
uniform float uSeed;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(float n) {
  return fract(sin(n * 127.1 + 311.7) * 43758.5453123);
}

float smoothNoise(float x, float seed) {
  float i = floor(x);
  float f = fract(x);
  float u = f * f * (3.0 - 2.0 * f);
  return mix(hash(i + seed), hash(i + 1.0 + seed), u) * 2.0 - 1.0;
}

float interpolant(float x, int levels, float rough, float seed) {
  float y = 0.35 * sin(6.28318 * x + seed);
  float amp = 0.42;
  float freq = 1.0;
  for (int i = 0; i < 14; i++) {
    if (i >= levels) break;
    y += amp * smoothNoise(x * freq + 0.11 * sin(uTime * 0.00008), seed + float(i) * 13.7);
    freq *= 2.0;
    amp *= rough;
  }
  return y * 0.55;
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.50);
  vec3 b = vec3(0.50);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.04, 0.16, 0.22); b = vec3(0.18, 0.38, 0.45); d = vec3(0.08, 0.28, 0.58); }
  else if (s < 5.0) { a = vec3(0.30, 0.13, 0.05); b = vec3(0.48, 0.25, 0.11); c = vec3(1.0, 0.8, 0.45); d = vec3(0.0, 0.12, 0.25); }
  return a + b * cos(6.28318 * (c * t + d));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = uv * 2.65 / max(uZoom, 0.0001) + uCenter;

  int levels = int(clamp(uIterations / 10.0, 4.0, 14.0));
  float rough = clamp(uRoughness, 0.2, 0.9);
  float seed = uSeed * 17.0;
  float x = p.x * 0.42 + 0.5;

  float y0 = interpolant(x, levels, rough, seed);
  float y1 = interpolant(x + 0.004, levels, rough, seed);
  float slope = abs(y1 - y0) / 0.004;
  float d = abs(p.y - y0);
  float line = 1.0 - smoothstep(0.012, 0.038, d / (1.0 + 0.08 * slope));
  float glow = exp(-d * 28.0);

  // Surface-like ghost copies show the same affine roughness as a stack of contours.
  float contours = 0.0;
  for (int i = -3; i <= 3; i++) {
    float off = float(i) * 0.22;
    contours += exp(-abs(p.y - y0 - off) * 28.0) * 0.08;
  }

  float control = 0.0;
  for (int i = 0; i < 9; i++) {
    float cx = float(i) / 8.0;
    float cy = interpolant(cx, 3, rough, seed);
    control += exp(-length(vec2(x, p.y) - vec2(cx, cy)) * 95.0);
  }

  vec3 bg = vec3(0.007, 0.009, 0.016) + vec3(0.02, 0.015, 0.03) * (p.y + 1.2);
  vec3 ink = palette(fract(x + y0 + seed * 0.01), uColorScheme);
  vec3 color = bg;
  color = mix(color, ink * 0.7, clamp(contours, 0.0, 0.45));
  color = mix(color, ink * (0.9 + 0.4 * glow), max(line, glow * 0.25));
  color += vec3(1.0, 0.9, 0.55) * control * 0.15;

  float alpha = uTransparentBg > 0.5 ? max(max(line, glow * 0.3), contours) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
