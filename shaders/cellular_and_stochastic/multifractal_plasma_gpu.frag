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
uniform float uLacunarity;
uniform float uIntermittency;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(vec2 p) {
  p = fract(p * vec2(234.34, 435.21));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float cascade(vec2 p, int octaves, float lacunarity, float intermittency) {
  float value = 0.0;
  float amp = 0.62;
  float product = 1.0;
  float freq = 1.0;
  for (int i = 0; i < 12; i++) {
    if (i >= octaves) break;
    float n = noise(p * freq);
    float ridge = 1.0 - abs(2.0 * n - 1.0);
    product *= mix(0.72, 1.38, ridge * intermittency);
    value += amp * product * ridge;
    freq *= lacunarity;
    amp *= 0.55;
    p = mat2(0.82, -0.57, 0.57, 0.82) * p + vec2(7.1, 3.4);
  }
  return value;
}

vec3 plasmaPalette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.03, 0.02, 0.10);
  vec3 b = vec3(0.25, 0.06, 0.45);
  vec3 c = vec3(0.95, 0.34, 0.08);
  vec3 d = vec3(1.00, 0.92, 0.48);
  if (s < 2.0) {
    a = vec3(0.01, 0.04, 0.10); b = vec3(0.02, 0.25, 0.45);
    c = vec3(0.25, 0.80, 1.00); d = vec3(0.92, 0.98, 1.00);
  } else if (s > 4.5) {
    a = vec3(0.08, 0.01, 0.02); b = vec3(0.35, 0.04, 0.02);
    c = vec3(0.95, 0.20, 0.04); d = vec3(1.00, 0.78, 0.16);
  }
  if (t < 0.33) return mix(a, b, smoothstep(0.0, 0.33, t));
  if (t < 0.74) return mix(b, c, smoothstep(0.33, 0.74, t));
  return mix(c, d, smoothstep(0.74, 1.0, t));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 4.0 / max(uZoom, 0.0001) + uCenter;

  int octaves = int(clamp(uIterations * 0.125, 3.0, 12.0));
  float lac = clamp(uLacunarity, 1.5, 3.5);
  float inter = clamp(uIntermittency, 0.2, 1.2);
  vec2 drift = vec2(0.025, -0.018) * uTime * 0.001;
  vec2 warp = vec2(cascade(p * 0.55 + drift, octaves, lac, inter),
                   cascade(p * 0.55 - drift + 9.37, octaves, lac, inter));
  vec2 q = p + (warp - 0.75) * 1.15;

  float v = cascade(q, octaves, lac, inter);
  float bands = 0.5 + 0.5 * sin(v * 8.5 + cascade(q * 1.8 + 4.2, octaves, lac, inter) * 3.0);
  float plasma = smoothstep(0.20, 1.45, v) * 0.72 + bands * 0.28;
  float filaments = pow(max(0.0, 1.0 - abs(fract(v * 5.0) - 0.5) * 2.0), 5.0);

  vec3 color = plasmaPalette(clamp(plasma, 0.0, 1.0), uColorScheme);
  color += vec3(1.0, 0.88, 0.55) * filaments * 0.35;
  color *= 0.82 + 0.20 * noise(q * 12.0);

  float alpha = uTransparentBg > 0.5 ? smoothstep(0.04, 0.22, plasma) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
