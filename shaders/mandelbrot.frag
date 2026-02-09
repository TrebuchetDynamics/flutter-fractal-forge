#include <flutter/runtime_effect.glsl>

precision highp float;

// Basic uniforms (indices 0-9)
uniform float uTime;          // 0
uniform vec2 uResolution;     // 1-2
uniform vec2 uCenter;         // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

// Custom palette uniforms (indices 10+)
uniform float uCustomStopCount; // 10
uniform vec4 uCustomStop0;      // 11-14
uniform vec4 uCustomStop1;      // 15-18
uniform vec4 uCustomStop2;      // 19-22
uniform vec4 uCustomStop3;      // 23-26
uniform vec4 uCustomStop4;      // 27-30
uniform vec4 uCustomStop5;      // 31-34
uniform vec4 uCustomStop6;      // 35-38
uniform vec4 uCustomStop7;      // 39-42

out vec4 fragColor;

// Get color from custom palette at position t (0-1)
vec3 samplePalette(float t) {
    // Clamp t to valid range
    t = clamp(t, 0.0, 1.0);
    
    // Find the two stops to interpolate between
    vec4 stops[8];
    stops[0] = uCustomStop0;
    stops[1] = uCustomStop1;
    stops[2] = uCustomStop2;
    stops[3] = uCustomStop3;
    stops[4] = uCustomStop4;
    stops[5] = uCustomStop5;
    stops[6] = uCustomStop6;
    stops[7] = uCustomStop7;
    
    int count = int(uCustomStopCount);
    if (count < 1) count = 1;
    if (count > 8) count = 8;
    
    // Find stops bracketing t
    vec3 colorA = stops[0].rgb;
    vec3 colorB = stops[0].rgb;
    float posA = stops[0].a;
    float posB = stops[0].a;
    
    for (int i = 0; i < 8; i++) {
        if (i >= count) break;
        if (stops[i].a <= t) {
            colorA = stops[i].rgb;
            posA = stops[i].a;
        }
    }
    for (int i = 7; i >= 0; i--) {
        if (i >= count) continue;
        if (stops[i].a >= t) {
            colorB = stops[i].rgb;
            posB = stops[i].a;
        }
    }
    
    // Interpolate
    float range = posB - posA;
    if (range < 0.001) return colorA;
    float blend = (t - posA) / range;
    return mix(colorA, colorB, blend);
}

// Built-in color palettes (fallback)
vec3 builtinPalette(float t, int scheme) {
    if (scheme == 0) {
        // Fire
        return vec3(
            0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.0)),
            0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.33)),
            0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.67))
        );
    } else if (scheme == 1) {
        // Ocean
        return vec3(
            0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.5)),
            0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.6)),
            0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.7))
        );
    } else if (scheme == 2) {
        // Psychedelic
        return vec3(
            0.5 + 0.5 * sin(6.28318 * t * 3.0),
            0.5 + 0.5 * sin(6.28318 * t * 5.0 + 2.0),
            0.5 + 0.5 * sin(6.28318 * t * 7.0 + 4.0)
        );
    } else {
        // Grayscale
        return vec3(t);
    }
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    
    // Normalize coordinates
    vec2 uv = (fragCoord - 0.5 * uResolution) / min(uResolution.x, uResolution.y);
    
    // Apply zoom and pan
    vec2 c = uv / uZoom + uCenter;
    
    // Mandelbrot iteration
    vec2 z = vec2(0.0);
    float i = 0.0;
    float bailoutSq = uBailout * uBailout;

    // NOTE: Some Android GPU drivers/compilers (and/or Impeller) behave badly
    // with non-constant loop bounds. Use a fixed maximum and break.
    const int MAX_ITERS = 500;
    for (int j = 0; j < MAX_ITERS; j++) {
        if (float(j) >= uIterations) {
            i = uIterations;
            break;
        }

        // z = z^2 + c
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

        if (dot(z, z) > bailoutSq) {
            i = float(j);
            break;
        }

        // If we never bail out, i will be set to uIterations above.
        i = float(j) + 1.0;
    }
    
    // Color based on iteration count
    if (i >= uIterations) {
        // Inside the set
        if (uTransparentBg > 0.5) {
            fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        } else {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
    } else {
        // Smooth coloring
        float smoothed = i - log2(log2(dot(z, z))) + 4.0;
        float t = smoothed / uIterations;
        
        // Use uTime for subtle animation
        t = fract(t + uTime * 0.01);
        
        // Use custom palette if stops are set, otherwise built-in
        vec3 color;
        if (uCustomStopCount > 0.5) {
            color = samplePalette(t);
        } else {
            color = builtinPalette(t, int(uColorScheme));
        }
        
        fragColor = vec4(color, 1.0);
    }
}
