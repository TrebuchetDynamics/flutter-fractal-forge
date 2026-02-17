// Test shader using FlutterFragCoord() to compare against gl_FragCoord

#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uResolution;

out vec4 fragColor;

void main() {
    // Use Flutter's helper function
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / max(uResolution, vec2(1.0));

    // Output UV gradient
    fragColor = vec4(uv.x, 0.5, uv.y, 1.0);
}
