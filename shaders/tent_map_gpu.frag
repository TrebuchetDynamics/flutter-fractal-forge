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

  // (mu, x0) plane for tent map x' = mu * min(x, 1-x).
  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  float mu = clamp(p.x, 0.0, 2.0);
  float x = clamp(p.y, 1e-9, 1.0 - 1e-9);

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));

  const int warmup = 64;
  for (int i = 0; i < warmup; i++) {
    x = mu * min(x, 1.0 - x);
    x = clamp(x, 1e-9, 1.0 - 1e-9);
  }

  float sum = 0.0;
  float varAcc = 0.0;
  float prev = x;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;
    x = mu * min(x, 1.0 - x);
    x = clamp(x, 1e-9, 1.0 - 1e-9);
    sum += x;
    varAcc += abs(x - prev);
    prev = x;
  }

  float mean = sum / float(target);
  float variation = clamp(varAcc / float(target), 0.0, 1.0);

  // Tent map Lyapunov is log(mu) almost everywhere when mu>0.
  float lyap = log(max(mu, 1e-9));
  float chaos = smoothstep(0.0, 0.4, lyap) * variation;
  float t = fract(0.60 * mean + 0.40 * chaos + 0.00006 * uTime);

  vec3 color = getPaletteColor(t, int(uColorScheme));
  float alpha = (uTransparentBg > 0.5 && mu < 0.15) ? 0.0 : 1.0;
  fragColor = vec4(color, alpha);
}
