#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / max(uSize, vec2(1.0));
  fragColor = vec4(uv.x, 0.25, uv.y, 1.0);
}
