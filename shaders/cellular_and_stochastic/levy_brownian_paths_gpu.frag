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
uniform float uPathMode;
uniform float uJumpiness;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(float n) { return fract(sin(n * 127.1 + 311.7) * 43758.5453123); }

float segDist(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
  return length(pa - ba * h);
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.50);
  vec3 b = vec3(0.50);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.04, 0.10, 0.20); b = vec3(0.20, 0.35, 0.55); d = vec3(0.55, 0.25, 0.05); }
  else if (s < 5.0) { a = vec3(0.28, 0.12, 0.05); b = vec3(0.55, 0.25, 0.10); c = vec3(1.0, 0.8, 0.45); d = vec3(0.0, 0.13, 0.29); }
  return a + b * cos(6.28318 * (c * t + d));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 3.2 / max(uZoom, 0.0001) + uCenter;

  int steps = int(clamp(uIterations * 0.55, 24.0, 96.0));
  float mode = floor(clamp(uPathMode, 0.0, 2.0) + 0.5);
  float jump = clamp(uJumpiness, 0.2, 2.5);
  vec2 pos = vec2(0.0);
  float d = length(p - pos);
  float age = 0.0;
  float glow = 0.0;

  for (int i = 0; i < 96; i++) {
    if (i >= steps) break;
    float fi = float(i);
    float a = 6.2831853 * hash(fi + 13.7) + 0.35 * sin(fi * 0.37 + uTime * 0.0002);
    float len = 0.055;
    if (mode < 0.5) {
      len = 0.06 + 0.025 * hash(fi + 9.0);
    } else if (mode < 1.5) {
      len = 0.035 + pow(max(hash(fi + 9.0), 0.03), -0.72) * 0.035 * jump;
    } else {
      len = 0.035 + 0.11 * (0.5 + 0.5 * sin(fi * 2.399963 + uTime * 0.0001)) * jump;
      a += sin(fi * 2.399963) * 1.3;
    }
    len = min(len, 0.42);
    vec2 next = clamp(pos + vec2(cos(a), sin(a)) * len, vec2(-1.25), vec2(1.25));
    float local = segDist(p, pos, next);
    if (local < d) {
      d = local;
      age = fi / max(float(steps), 1.0);
    }
    glow += exp(-local * 34.0) * 0.014;
    pos = next;
  }

  float line = 1.0 - smoothstep(0.012, 0.035, d);
  float endpoint = exp(-length(p - pos) * 35.0);
  vec3 color = palette(fract(age + glow * 0.8), uColorScheme) * max(line, glow * 0.55);
  color += vec3(1.0, 0.82, 0.35) * endpoint * 0.22;
  float alpha = max(line, glow * 0.55);
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.006, 0.007, 0.014), color, clamp(alpha, 0.0, 1.0));
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
