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
uniform float uWarp;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p, int octaves, float roughness) {
  float v = 0.0;
  float amp = 0.5;
  float freq = 1.0;
  for (int i = 0; i < 12; i++) {
    if (i >= octaves) break;
    v += amp * noise(p * freq);
    freq *= 2.03;
    amp *= roughness;
    p = mat2(0.8, -0.6, 0.6, 0.8) * p + 7.13;
  }
  return v;
}

float ridged(vec2 p, int octaves, float roughness) {
  float v = 0.0;
  float amp = 0.55;
  float freq = 1.0;
  for (int i = 0; i < 12; i++) {
    if (i >= octaves) break;
    float n = 1.0 - abs(2.0 * noise(p * freq) - 1.0);
    v += amp * n * n;
    freq *= 2.08;
    amp *= roughness;
    p = mat2(0.65, -0.76, 0.76, 0.65) * p + 3.7;
  }
  return v;
}

vec3 terrainColor(float h, float slope, float scheme) {
  vec3 water = vec3(0.02, 0.12, 0.28);
  vec3 sand = vec3(0.55, 0.43, 0.24);
  vec3 grass = vec3(0.10, 0.34, 0.12);
  vec3 rock = vec3(0.38, 0.35, 0.32);
  vec3 snow = vec3(0.85, 0.88, 0.90);
  if (mod(scheme, 4.0) >= 2.0) {
    water = vec3(0.04, 0.03, 0.11);
    sand = vec3(0.35, 0.18, 0.45);
    grass = vec3(0.15, 0.35, 0.48);
    rock = vec3(0.55, 0.42, 0.70);
    snow = vec3(0.95, 0.86, 0.65);
  }
  vec3 col = water;
  col = mix(col, sand, smoothstep(0.30, 0.36, h));
  col = mix(col, grass, smoothstep(0.36, 0.52, h));
  col = mix(col, rock, smoothstep(0.52, 0.72, h));
  col = mix(col, snow, smoothstep(0.72, 0.88, h));
  col *= 0.72 + 0.45 * slope;
  return col;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = uv / max(uZoom, 0.0001) + uCenter;

  int octaves = int(clamp(uIterations * 0.25, 1.0, 12.0));
  float roughness = clamp(uRoughness, 0.2, 0.9);
  vec2 drift = vec2(0.03, -0.02) * uTime * 0.001;
  vec2 warp = vec2(fbm(p * 2.0 + drift, octaves, roughness),
                   fbm(p * 2.0 - drift + 19.7, octaves, roughness)) - 0.5;
  vec2 q = p * 3.0 + warp * clamp(uWarp, 0.0, 2.0);

  float h = 0.58 * fbm(q, octaves, roughness) + 0.55 * ridged(q * 1.15 + 4.0, octaves, roughness);
  h = smoothstep(0.20, 1.05, h);

  float e = 1.5 / scale;
  float hx = fbm(q + vec2(e, 0.0), octaves, roughness);
  float hy = fbm(q + vec2(0.0, e), octaves, roughness);
  float slope = clamp(0.7 + (h - hx) * 4.0 + (h - hy) * 3.0, 0.0, 1.4);

  vec3 color = terrainColor(h, slope, uColorScheme);
  float contour = abs(fract(h * 18.0) - 0.5);
  color *= 0.82 + 0.18 * smoothstep(0.02, 0.08, contour);

  float alpha = (uTransparentBg > 0.5 && h < 0.05) ? 0.0 : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
