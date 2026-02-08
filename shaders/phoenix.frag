#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uPhoenixP;
uniform float uCustomStopCount;
uniform vec4 uCustomStop0;
uniform vec4 uCustomStop1;
uniform vec4 uCustomStop2;
uniform vec4 uCustomStop3;
uniform vec4 uCustomStop4;
uniform vec4 uCustomStop5;
uniform vec4 uCustomStop6;
uniform vec4 uCustomStop7;

out vec4 fragColor;

// Color palettes
vec3 palette(float t, int scheme) {
    if (scheme == 0) {
        // Fire - warm oranges and reds
        return vec3(
            0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
            0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
            0.5 + 0.5 * cos(6.28318 * (t + 0.7))
        );
    } else if (scheme == 1) {
        // Ocean - cool blues and teals
        return vec3(
            0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
            0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
            0.5 + 0.5 * cos(6.28318 * (t + 0.0))
        );
    } else if (scheme == 2) {
        // Psychedelic - vibrant rainbow
        return vec3(
            0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
            0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
            0.5 + 0.5 * cos(6.28318 * (t + 0.67))
        );
    } else {
        // Grayscale
        float g = 0.5 + 0.5 * cos(6.28318 * t);
        return vec3(g, g, g);
    }
}

void main() {
    // Normalize coordinates (FlutterFragCoord is required for Skia/Flutter)
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) / min(uResolution.x, uResolution.y);
    
    // Apply zoom and pan - c is the point on complex plane
    vec2 c = uv / uZoom + uCenter;
    
    // Phoenix fractal: z[n+1] = z[n]^2 + Re(c) + Im(c)*p*z[n-1]
    // where p is a parameter (uPhoenixP)
    vec2 z = c;
    vec2 zPrev = vec2(0.0);
    float p = uPhoenixP;  // Phoenix parameter
    
    float iterations = 0.0;
    int maxIter = int(uIterations);
    float bailoutSq = uBailout * uBailout;
    
    for (int i = 0; i < 500; i++) {
        if (i >= maxIter) break;
        
        // Phoenix iteration: z = z^2 + c.x + c.y * p * zPrev
        vec2 zNew;
        zNew.x = z.x * z.x - z.y * z.y + c.x + c.y * p * zPrev.x;
        zNew.y = 2.0 * z.x * z.y + c.y * p * zPrev.y;
        
        zPrev = z;
        z = zNew;
        
        if (dot(z, z) > bailoutSq) {
            // Smooth iteration count
            iterations = float(i) - log2(log2(dot(z, z))) + 4.0;
            break;
        }
        iterations = float(i);
    }
    
    // Color based on iteration count
    if (dot(z, z) <= bailoutSq) {
        // Inside the set - black or transparent
        if (uTransparentBg > 0.5) {
            fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        } else {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
    } else {
        // Outside - colorful gradient
        float t = iterations / uIterations;
        vec3 color = palette(t + uTime * 0.0001, int(uColorScheme));
        fragColor = vec4(color, 1.0);
    }
}
