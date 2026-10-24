#version 460 core
#include <flutter/runtime_effect.glsl>

// Same family contract as FibonacciComplexModel. Discrete k bands, no
// quadratic log-2 smoothing, no time evolution or runtime primality search.
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform vec2 uC;
uniform float uTransparentBg;
out vec4 fragColor;

bool finiteFloat(float x) {
    return abs(x) <= 3.402823e38;
}
bool finiteComplex(vec2 z) {
    return finiteFloat(z.x) && finiteFloat(z.y);
}
float magnitude(vec2 z) {
    float s = max(abs(z.x), abs(z.y));
    if (s == 0.0) return 0.0;
    return s * length(z / s);
}
bool exceeds(vec2 z, float radius) {
    float s = max(abs(z.x), abs(z.y));
    if (s > radius) return true;
    if (s == 0.0) return false;
    return s > radius / length(z / s);
}
bool primeDegree(int k) {
    return k == 1 || k == 2 || k == 3 || k == 5 || k == 9 ||
           k == 11 || k == 15 || k == 21 || k == 27 || k == 41 || k == 45;
}
vec4 diagnostic() {
    // Numeric uncertainty must never masquerade as escape or transparent cap.
    return vec4(230.0, 40.0, 190.0, 255.0) / 255.0;
}
void main() {
    if (!finiteComplex(uC) || !finiteComplex(uCenter) ||
        !finiteFloat(uZoom) || uZoom <= 0.0 ||
        !finiteFloat(uBailout) || uBailout <= 0.0) {
        fragColor = diagnostic();
        return;
    }
    vec2 uv = (FlutterFragCoord().xy / uResolution) * 2.0 - 1.0;
    uv.x *= uResolution.x / uResolution.y;
    vec2 z = uCenter + uv * (1.5 / max(uZoom, 1e-9));
    vec2 w = z;
    float radius = max(2.0 + magnitude(uC), uBailout);
    if (!finiteComplex(z) || !finiteFloat(radius)) {
        fragColor = diagnostic();
        return;
    }
    int cap = int(clamp(floor(uIterations + 0.5), 1.0, 45.0));
    for (int k = 0; k <= 45; ++k) {
        // Inspect initial and final states BEFORE the next multiplication.
        if (exceeds(z, radius) && exceeds(w, radius)) {
            float band = mod(float(k), 6.0);
            vec3 rgb = primeDegree(k)
                ? vec3(255.0, 180.0 + 5.0 * band, 40.0)
                : vec3(30.0 + 5.0 * band, 90.0 + 12.0 * band, 170.0 + 12.0 * band);
            fragColor = vec4(rgb / 255.0, 1.0);
            return;
        }
        if (k == cap) {
            fragColor = uTransparentBg > 0.5 ? vec4(0.0)
                : vec4(12.0, 18.0, 30.0, 255.0) / 255.0;
            return;
        }
        vec2 nextZ = vec2(z.x*w.x - z.y*w.y, z.x*w.y + z.y*w.x) + uC;
        if (!finiteComplex(nextZ)) {
            fragColor = diagnostic();
            return;
        }
        w = z;
        z = nextZ;
    }
    fragColor = diagnostic();
}
