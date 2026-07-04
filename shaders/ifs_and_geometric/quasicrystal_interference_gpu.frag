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
uniform float uSymmetry;
uniform float uSharpness;
uniform float uPhase;

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

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  if (s < 1.0) return iqPalette(t, vec3(0.50), vec3(0.50), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s < 2.0) return iqPalette(t, vec3(0.14, 0.12, 0.32), vec3(0.45, 0.25, 0.55), vec3(1.0, 0.8, 0.5), vec3(0.58, 0.22, 0.03));
  if (s < 3.0) return iqPalette(t, vec3(0.10, 0.24, 0.28), vec3(0.25, 0.42, 0.44), vec3(0.8, 1.0, 1.2), vec3(0.20, 0.38, 0.65));
  return iqPalette(t, vec3(0.48), vec3(0.50), vec3(1.0, 0.7, 0.4), vec3(fract(s * 0.173), 0.31, 0.69));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = (uv / max(uZoom, 0.0001) + uCenter) * 7.0;

  float symmetry = floor(clamp(uSymmetry, 5.0, 14.0) + 0.5);
  float phase = uPhase + uTime * 0.00008;
  float wave = 0.0;
  float ridges = 1.0;
  float stars = 0.0;

  for (int i = 0; i < 16; i++) {
    float fi = float(i);
    if (fi >= symmetry) break;
    float a = 6.2831853 * fi / symmetry;
    vec2 dir = vec2(cos(a), sin(a));
    float v = cos(dot(p, dir) + phase + 0.31 * sin(fi * 1.7));
    wave += v;
    ridges *= 0.58 + 0.42 * abs(v);
    stars += pow(max(0.0, v), clamp(uSharpness, 0.5, 8.0));
  }

  wave /= max(symmetry, 1.0);
  stars /= max(symmetry, 1.0);
  float field = 0.45 + 0.35 * wave + 0.45 * ridges + 0.65 * stars;
  float crystal = smoothstep(0.62, 0.92, field);
  float lines = smoothstep(0.02, 0.0, abs(fract(field * 8.0) - 0.5));

  vec3 color = palette(fract(field * 0.37 + stars * 0.8), uColorScheme);
  color *= 0.28 + 0.9 * crystal;
  color += vec3(0.9, 0.95, 1.0) * lines * 0.35;
  color *= 0.9 + 0.25 * cos(length(p) * 0.35);

  float alpha = (uTransparentBg > 0.5 && crystal < 0.06) ? 0.0 : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
