#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution; // 0-1
uniform sampler2D uTex;   // sampler index 0

out vec4 fragColor;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uResolution, vec2(1.0));
  // sample a 1x1 texture; if sampler works, screen should be that color
  vec3 c = texture(uTex, vec2(0.5, 0.5)).rgb;
  fragColor = vec4(mix(c, vec3(uv.x, uv.y, 1.0-uv.x), 0.2), 1.0);
}
