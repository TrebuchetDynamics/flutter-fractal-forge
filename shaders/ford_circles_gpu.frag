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

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p.x = p.x * 3.5;
  p.y = p.y * 2.5 + 0.55;

  int target = int(clamp(uIterations, 8.0, float(MAX_ITERS)));
  int qMax = int(clamp(float(target) * 0.35, 8.0, 64.0));

  float best = 1e9;
  float bestQ = 1.0;
  float fill = 0.0;

  for (int q = 1; q <= 64; q++) {
    if (q > qMax) break;
    float fq = float(q);
    float r = 1.0 / (2.0 * fq * fq);

    for (int pNum = 0; pNum <= 64; pNum++) {
      if (pNum > q) break;
      float fp = float(pNum);
      float x = fp / fq;

      vec2 c = vec2(x, r);
      float d = length(p - c) - r;
      float ad = abs(d);

      if (ad < best) {
        best = ad;
        bestQ = fq;
        fill = (d <= 0.0) ? 1.0 : 0.0;
      }
    }
  }

  float edge = exp(-95.0 * best);
  float inside = smoothstep(0.002, -0.004, best) * fill;

  if (max(edge, inside) < 0.01 && p.y > 0.0) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float denomNorm = clamp(log(bestQ + 1.0) / log(float(qMax) + 1.0), 0.0, 1.0);
  float t = fract(denomNorm + 0.2 * edge + 0.03 * uTime * 0.001);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= mix(0.35, 1.1, max(edge, inside));

  if (p.y < 0.0) {
    float axis = exp(-140.0 * abs(p.y));
    color = mix(color, vec3(0.9), axis * 0.8);
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
