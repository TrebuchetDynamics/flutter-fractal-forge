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
uniform float uForcing;
uniform float uFolding;

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
  if (s < 2.0) { a = vec3(0.05, 0.10, 0.22); b = vec3(0.22, 0.32, 0.55); d = vec3(0.55, 0.20, 0.06); }
  else if (s < 5.0) { a = vec3(0.20, 0.08, 0.22); b = vec3(0.45, 0.18, 0.55); c = vec3(1.0, 0.7, 0.5); d = vec3(0.62, 0.27, 0.08); }
  return a + b * cos(6.28318 * (c * t + d));
}

float wrapPi(float x) {
  return mod(x + 3.14159265, 6.2831853) - 3.14159265;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = uv * 3.0 / max(uZoom, 0.0001) + uCenter;

  float forcing = clamp(uForcing, 0.1, 1.2);
  float folding = clamp(uFolding, 0.4, 2.4);
  float golden = 2.39996323;
  int steps = int(clamp(uIterations, 40.0, 220.0));

  float density = 0.0;
  float minD = 10.0;
  float x = 0.17 + 0.05 * sin(uTime * 0.0001);
  float theta = 0.31;

  for (int i = 0; i < 220; i++) {
    if (i >= steps) break;
    theta = mod(theta + golden, 6.2831853);
    x = wrapPi(folding * sin(x) + forcing * cos(theta) + 0.22 * sin(2.0 * theta));
    if (i > 16) {
      vec2 q = vec2(theta / 3.14159265 - 1.0, x / 2.2);
      float d = length((p - q) * vec2(1.2, 1.0));
      minD = min(minD, d);
      density += exp(-d * 85.0);
      // Mirror branch emphasizes quasiperiodic ribbons.
      vec2 q2 = vec2(q.x, -0.72 * q.y + 0.16 * sin(theta * 3.0));
      float d2 = length((p - q2) * vec2(1.2, 1.0));
      minD = min(minD, d2);
      density += exp(-d2 * 80.0) * 0.65;
    }
  }

  density = 1.0 - exp(-density * 0.035);
  float ribbon = exp(-minD * 22.0);
  float phase = fract(p.x * 0.22 + p.y * 0.17 + density * 0.8);
  vec3 bg = vec3(0.006, 0.007, 0.014) + vec3(0.018, 0.012, 0.035) * (p.y + 1.1);
  vec3 ink = palette(phase, uColorScheme) * (0.55 + 1.1 * density);
  vec3 color = mix(bg, ink, max(density, ribbon * 0.25));
  color += vec3(0.8, 0.9, 1.0) * pow(ribbon, 3.0) * 0.25;

  float alpha = uTransparentBg > 0.5 ? max(density, ribbon * 0.3) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
