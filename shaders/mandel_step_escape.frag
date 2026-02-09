#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uTransparentBg;

out vec4 fragColor;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  vec2 z = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Simple coloring: no log/log smoothing, no palettes.
  float t = float(it) / max(1.0, uIterations);
  // make it obviously non-black
  vec3 col = vec3(t, 0.2 + 0.8 * (1.0 - t), 0.5 + 0.5 * sin(uTime * 0.001));
  fragColor = vec4(col, 1.0);
}
