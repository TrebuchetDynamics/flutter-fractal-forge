#include <flutter/runtime_effect.glsl>

precision mediump float;

// Keep uniform layout EXACTLY aligned with Dart setFloat indices.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

uniform float uCustomStopCount; // 10
uniform vec4  uCustomStop0;     // 11-14
uniform vec4  uCustomStop1;     // 15-18
uniform vec4  uCustomStop2;     // 19-22
uniform vec4  uCustomStop3;     // 23-26
uniform vec4  uCustomStop4;     // 27-30
uniform vec4  uCustomStop5;     // 31-34
uniform vec4  uCustomStop6;     // 35-38
uniform vec4  uCustomStop7;     // 39-42

out vec4 fragColor;

// Minimal shader for driver/engine diagnosis:
// - NO loops
// - Still references ALL uniforms so Impeller won't drop them.
void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uResolution, vec2(1.0));

  // Touch scalar uniforms.
  float s = uTime + uZoom + uIterations + uBailout + uColorScheme + uTransparentBg + uCustomStopCount;

  // Touch vec uniforms.
  s += uCenter.x + uCenter.y;

  // Touch all palette stops (but don't actually use them).
  s += dot(uCustomStop0, vec4(1.0));
  s += dot(uCustomStop1, vec4(1.0));
  s += dot(uCustomStop2, vec4(1.0));
  s += dot(uCustomStop3, vec4(1.0));
  s += dot(uCustomStop4, vec4(1.0));
  s += dot(uCustomStop5, vec4(1.0));
  s += dot(uCustomStop6, vec4(1.0));
  s += dot(uCustomStop7, vec4(1.0));

  // Use s in a way that can't be optimized out.
  float wobble = fract(s * 0.001);

  fragColor = vec4(uv.x, wobble, uv.y, 1.0);
}
