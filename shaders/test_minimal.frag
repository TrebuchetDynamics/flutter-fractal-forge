// Minimal test shader for SwiftShader debugging
// Test 1: Just output a constant color - no uniforms, no functions

precision mediump float;

out vec4 fragColor;

void main() {
    // Simplest possible shader - just output solid red
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
