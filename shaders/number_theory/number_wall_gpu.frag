#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution;
uniform vec2 uGridSize;
uniform vec4 uRect;
uniform sampler2D uGrid;

out vec4 fragColor;

void main() {
  vec2 uv = (FlutterFragCoord().xy - uRect.xy) / max(uRect.zw, vec2(1.0));
  vec2 cell = floor(uv * uGridSize);
  vec2 center = (cell + vec2(0.5)) / max(uGridSize, vec2(1.0));
  fragColor = texture(uGrid, center);
}
