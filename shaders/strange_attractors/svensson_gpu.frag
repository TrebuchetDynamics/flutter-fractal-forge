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
uniform float uA;
uniform float uB;
uniform float uC;
uniform float uD;

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
  float x = p.x;
  float y = p.y;

  float a = uA;
  float b = uB;
  float c = uC;
  float d = uD;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailoutSq = max(1.0, uBailout * uBailout);

  int it = target;
  float density = 0.0;
  float lace = 0.0;
  float trap = 1e9;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    float nx = d * sin(a * x) - sin(b * y);
    float ny = c * cos(a * x) + cos(b * y);
    x = nx;
    y = ny;

    float r2 = x * x + y * y;
    float thread = min(abs(sin(8.0 * x + 3.0 * y)), abs(sin(3.0 * x - 7.0 * y)));
    trap = min(trap, thread);
    density += 1.0 / (1.0 + 0.3 * r2);
    lace += 1.0 / ((1.0 + 14.0 * thread) * (1.0 + 0.08 * r2));
    if (r2 > bailoutSq) {
      it = i + 1;
      break;
    }
  }

  if (it >= target) {
    float normLace = lace / float(target);
    float screenThread = min(abs(sin(18.0 * p.x + 7.0 * p.y)), abs(sin(7.0 * p.x - 17.0 * p.y)));
    float screenLace = exp(-10.0 * screenThread);
    float t = fract((density / float(target)) * 1.2 + normLace * 0.7 + screenLace * 0.25 + uTime * 0.00005);
    vec3 col = getPaletteColor(t, int(uColorScheme));
    float detail = 0.35 + 0.7 * sqrt(clamp(normLace * 2.0, 0.0, 1.0)) + 0.35 / (1.0 + 24.0 * trap) + 0.55 * screenLace;
    fragColor = vec4(linearToSRGB(col * detail), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float r2 = max(1e-12, x * x + y * y);
  float smoothVal = float(it) - log2(log2(r2));
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(getPaletteColor(t, int(uColorScheme))), 1.0);
}
