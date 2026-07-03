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

// Shared: linearToSRGB, iqPalette, getPaletteColor
#include "../shared/color.glsl"

const int MAX_ITERS = 500;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  // Use mapped parameters for Gauss map x' = exp(-a*x^2) + b
  float a = 6.2 + p.x;
  float b = -0.6 + p.y;
  float x = p.y;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailout = max(1.0, uBailout);

  int it = target;
  float accum = 0.0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;
    x = exp(-a * x * x) + b;
    accum += abs(x);

    if (abs(x) > bailout) {
      it = i;
      break;
    }
  }

  if (it >= target) {
    float orbit = accum / float(target);
    float t = fract(clamp(orbit * 0.35, 0.0, 1.0) + uTime * 0.00005);
    vec3 col = getPaletteColor(t, int(uColorScheme));
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.92 : 1.0);
    return;
  }

  float t = float(it) / max(1.0, float(target));
  vec3 color = getPaletteColor(t, int(uColorScheme));
  fragColor = vec4(linearToSRGB(color), 1.0);
}
