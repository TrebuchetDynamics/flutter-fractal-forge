// Test shader using gl_FragCoord (standard GLSL, not Flutter helper)

precision mediump float;

uniform vec2 uResolution;

out vec4 fragColor;

void main() {
    // Use standard gl_FragCoord instead of FlutterFragCoord()
    vec2 uv = gl_FragCoord.xy / max(uResolution, vec2(1.0));

    // Output UV gradient
    fragColor = vec4(uv.x, 0.5, uv.y, 1.0);
}
