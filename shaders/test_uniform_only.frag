#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uResolution;

out vec4 fragColor;

void main() {
    // If uResolution is set correctly, output green.
    // If uResolution.x is 0, output red.
    // This tests if uniforms are reaching the shader.

    if (uResolution.x > 100.0) {
        // Resolution is valid → GREEN
        fragColor = vec4(0.0, 1.0, 0.0, 1.0);
    } else {
        // Resolution is invalid or 0 → RED
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
