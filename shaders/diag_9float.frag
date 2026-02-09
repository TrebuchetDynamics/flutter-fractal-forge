#include <flutter/runtime_effect.glsl>

precision highp float;

// Same layout as mandelbrot_tex.frag but NO sampler
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
  vec2 uv = fragCoord / max(uResolution, vec2(1.0));

  // Touch all uniforms
  float s = uTime * 0.0001 + uZoom * 0.001 + uIterations * 0.001
          + uBailout * 0.01 + uTransparentBg * 0.01
          + uCenter.x * 0.01 + uCenter.y * 0.01;
  float wobble = fract(s);

  fragColor = vec4(uv.x, wobble, uv.y, 1.0);
}
