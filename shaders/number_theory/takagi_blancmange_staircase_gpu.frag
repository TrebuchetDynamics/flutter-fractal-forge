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
uniform float uMode;
uniform float uThickness;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.50);
  vec3 b = vec3(0.50);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 3.0) { a = vec3(0.08, 0.10, 0.18); b = vec3(0.35, 0.25, 0.52); d = vec3(0.55, 0.22, 0.08); }
  else if (s < 6.0) { a = vec3(0.32, 0.18, 0.06); b = vec3(0.48, 0.33, 0.12); c = vec3(1.0, 0.8, 0.45); d = vec3(0.0, 0.13, 0.29); }
  return a + b * cos(6.28318 * (c * t + d));
}

float tri(float x) {
  return abs(fract(x) - 0.5) * 2.0;
}

float takagi(float x, int terms) {
  float y = 0.0;
  float amp = 0.5;
  float freq = 1.0;
  for (int i = 0; i < 18; i++) {
    if (i >= terms) break;
    y += amp * tri(x * freq);
    freq *= 2.0;
    amp *= 0.5;
  }
  return y * 0.55;
}

float cantor(float x, int terms) {
  x = clamp(fract(x), 0.0, 1.0);
  float y = 0.0;
  float place = 0.5;
  for (int i = 0; i < 16; i++) {
    if (i >= terms) break;
    x *= 3.0;
    float digit = floor(x);
    if (digit > 1.5) {
      y += place;
    } else if (digit > 0.5) {
      y += place * 0.5;
      break;
    }
    x = fract(x);
    place *= 0.5;
  }
  return y;
}

float devil(float x, int terms) {
  float base = cantor(x, terms);
  float lock = floor(base * 18.0 + 0.5) / 18.0;
  return mix(base, lock, 0.55);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = uv * 2.7 / max(uZoom, 0.0001) + uCenter;

  float x = p.x * 0.42 + 0.5;
  float mode = floor(clamp(uMode, 0.0, 2.0) + 0.5);
  int terms = int(clamp(uIterations / 8.0, 4.0, 18.0));
  float y = takagi(x + 0.02 * sin(uTime * 0.0001), terms);
  if (mode > 0.5 && mode < 1.5) y = cantor(x, terms);
  if (mode > 1.5) y = devil(x + 0.01 * sin(uTime * 0.00008), terms);

  float graphY = (y - 0.5) * 2.0;
  float d = abs(p.y - graphY);
  float thickness = clamp(uThickness, 0.004, 0.05) / max(uZoom, 0.3);
  float graph = 1.0 - smoothstep(thickness, thickness * 2.6, d);
  float glow = exp(-d * 35.0);

  float grid = 0.0;
  grid += 1.0 - smoothstep(0.002, 0.008, abs(fract((p.x + 1.2) * 4.0) - 0.5));
  grid += 1.0 - smoothstep(0.002, 0.008, abs(fract((p.y + 1.2) * 4.0) - 0.5));
  grid *= 0.05;

  vec3 bg = vec3(0.008, 0.009, 0.016) + grid;
  vec3 ink = palette(fract(x + y + mode * 0.2), uColorScheme);
  vec3 color = mix(bg, ink * (0.65 + 0.6 * glow), max(graph, glow * 0.28));
  float alpha = uTransparentBg > 0.5 ? max(graph, glow * 0.35) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
