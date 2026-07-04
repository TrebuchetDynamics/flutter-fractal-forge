#include <flutter/runtime_effect.glsl>

precision mediump float;

// Keep the standard escape-time float layout so the catalog builder can drive
// this diagnostic surface without a custom module.
uniform float uTime;           // 0
uniform vec2  uResolution;     // 1-2
uniform vec2  uCenter;         // 3-4
uniform float uZoom;           // 5
uniform float uIterations;     // 6
uniform float uBailout;        // 7
uniform float uColorScheme;    // 8
uniform float uTransparentBg;  // 9

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / max(uResolution, vec2(1.0));
  float wobble = fract((uTime + uCenter.x + uCenter.y + uZoom +
      uIterations + uBailout + uColorScheme + uTransparentBg) * 0.001);
  fragColor = vec4(uv.x, 0.25 + 0.5 * wobble, uv.y, 1.0);
}
