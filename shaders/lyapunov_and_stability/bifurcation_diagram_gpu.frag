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
uniform float uMapVariant;
uniform float uSettle;

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
  vec3 a = vec3(0.5);
  vec3 b = vec3(0.5);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.05, 0.12, 0.25); b = vec3(0.25, 0.38, 0.55); d = vec3(0.58, 0.24, 0.05); }
  else if (s < 5.0) { a = vec3(0.32, 0.12, 0.03); b = vec3(0.55, 0.30, 0.08); c = vec3(1.0, 0.7, 0.4); d = vec3(0.0, 0.12, 0.26); }
  return a + b * cos(6.28318 * (c * t + d));
}

float mapStep(float x, float r, float variant) {
  if (variant < 0.5) return r * x * (1.0 - x);
  if (variant < 1.5) return r * min(x, 1.0 - x); // tent map, r in [1,2]
  return fract(r * sin(3.14159265 * x));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 p = uv * 2.35 / max(uZoom, 0.0001) + uCenter;

  float variant = floor(clamp(uMapVariant, 0.0, 2.0) + 0.5);
  float xNorm = clamp(p.x * 0.42 + 0.5, 0.0, 1.0);
  float y = clamp(p.y * 0.42 + 0.5, 0.0, 1.0);
  float r = mix(2.45, 4.0, xNorm);
  if (variant > 0.5 && variant < 1.5) r = mix(1.0, 2.0, xNorm);
  if (variant > 1.5) r = mix(1.0, 4.0, xNorm);

  float orbit = 0.217 + 0.03 * sin(uTime * 0.0001);
  int settleSteps = int(clamp(uSettle, 8.0, 96.0));
  int plotSteps = int(clamp(uIterations - uSettle, 24.0, 160.0));

  for (int i = 0; i < 96; i++) {
    if (i >= settleSteps) break;
    orbit = clamp(mapStep(orbit, r, variant), 0.0, 1.0);
  }

  float density = 0.0;
  float nearest = 1.0;
  for (int i = 0; i < 160; i++) {
    if (i >= plotSteps) break;
    orbit = clamp(mapStep(orbit, r, variant), 0.0, 1.0);
    float d = abs(y - orbit);
    nearest = min(nearest, d);
    density += exp(-d * 850.0 / max(uZoom, 0.35));
  }
  density = 1.0 - exp(-density * 0.11);
  float ridge = exp(-nearest * 1400.0 / max(uZoom, 0.35));

  float axis = max(1.0 - smoothstep(0.002, 0.008, abs(p.y + 1.18)),
                   1.0 - smoothstep(0.002, 0.008, abs(p.x + 1.18)));
  vec3 bg = vec3(0.006, 0.007, 0.013) + vec3(0.025, 0.018, 0.04) * xNorm;
  vec3 ink = palette(fract(xNorm * 0.6 + nearest * 20.0), uColorScheme) * (0.35 + 1.6 * density);
  vec3 color = mix(bg, ink, density);
  color += palette(fract(xNorm + 0.23), uColorScheme) * ridge * 0.42;
  color += vec3(0.45, 0.55, 0.75) * axis * 0.35;

  float alpha = uTransparentBg > 0.5 ? max(max(density, ridge), axis) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
