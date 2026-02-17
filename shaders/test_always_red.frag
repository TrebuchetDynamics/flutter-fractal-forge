#include <flutter/runtime_effect.glsl>

precision highp float;

out vec4 fragColor;

void main() {
    // ALWAYS output red, no matter what
    // No uniforms, no conditions, no math
    // This is the simplest possible shader
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
