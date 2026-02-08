#include <flutter/runtime_effect.glsl>

// Precision: use mediump for color calculations, highp for coordinates
precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

// Custom palette (for uColorScheme >= 4)
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

vec3 sampleCustomGradient(float t) {
    int n = int(uCustomStopCount + 0.5);
    // Use the first stop as default/fallback.
    vec4 s0 = uCustomStop0;
    vec4 s1 = uCustomStop1;
    vec4 s2 = uCustomStop2;
    vec4 s3 = uCustomStop3;
    vec4 s4 = uCustomStop4;
    vec4 s5 = uCustomStop5;
    vec4 s6 = uCustomStop6;
    vec4 s7 = uCustomStop7;

    if (n <= 1) {
        return s0.rgb;
    }

    vec3 col = s0.rgb;

    // Segment 0
    if (n > 1) {
        float a = s0.a;
        float b = s1.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s0.rgb, s1.rgb, w), useSeg);
        col = mix(col, s1.rgb, step(b, t));
    }
    if (n > 2) {
        float a = s1.a;
        float b = s2.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s1.rgb, s2.rgb, w), useSeg);
        col = mix(col, s2.rgb, step(b, t));
    }
    if (n > 3) {
        float a = s2.a;
        float b = s3.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s2.rgb, s3.rgb, w), useSeg);
        col = mix(col, s3.rgb, step(b, t));
    }
    if (n > 4) {
        float a = s3.a;
        float b = s4.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s3.rgb, s4.rgb, w), useSeg);
        col = mix(col, s4.rgb, step(b, t));
    }
    if (n > 5) {
        float a = s4.a;
        float b = s5.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s4.rgb, s5.rgb, w), useSeg);
        col = mix(col, s5.rgb, step(b, t));
    }
    if (n > 6) {
        float a = s5.a;
        float b = s6.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s5.rgb, s6.rgb, w), useSeg);
        col = mix(col, s6.rgb, step(b, t));
    }
    if (n > 7) {
        float a = s6.a;
        float b = s7.a;
        float w = clamp((t - a) / max(b - a, 1e-6), 0.0, 1.0);
        float useSeg = step(a, t) * (1.0 - step(b, t));
        col = mix(col, mix(s6.rgb, s7.rgb, w), useSeg);
        col = mix(col, s7.rgb, step(b, t));
    }

    return col;
}

// Branchless palette selection using smooth interpolation
vec3 palette(float t, float scheme) {
    if (scheme >= 3.5) {
        return sampleCustomGradient(t);
    }

    // Precompute all three palette options
    vec3 fire = vec3(0.2 + 0.8 * t, 0.1 + 0.3 * t, 0.05 + 0.2 * t);
    vec3 ocean = vec3(0.05 + 0.3 * t, 0.2 + 0.7 * t, 0.4 + 0.5 * t);
    vec3 psychedelic = vec3(
        0.5 + 0.5 * sin(6.2831 * t + uTime * 0.2),
        0.5 + 0.5 * sin(6.2831 * t + 2.0),
        0.5 + 0.5 * sin(6.2831 * t + 4.0)
    );
    vec3 gray = vec3(t);
    
    // Branchless selection using step functions
    float s0 = step(0.5, scheme);           // 0 if scheme < 0.5, else 1
    float s1 = step(1.5, scheme);           // 0 if scheme < 1.5, else 1
    float s2 = step(2.5, scheme);           // 0 if scheme < 2.5, else 1
    
    // Mix results without branches
    vec3 result = fire;
    result = mix(result, ocean, s0 * (1.0 - s1));
    result = mix(result, psychedelic, s1 * (1.0 - s2));
    result = mix(result, gray, s2);
    
    return result;
}

void main() {
    vec2 uv = (FlutterFragCoord().xy - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    
    // Precompute constants outside loop
    float invZoom = 1.0 / max(uZoom, 0.0001);
    vec2 c = uv * invZoom + uCenter;
    vec2 z = vec2(0.0);
    
    // LOD: Reduce iterations at low zoom levels for better performance
    // More zoom = more detail needed = more iterations
    float lodFactor = clamp(log2(uZoom + 1.0) * 0.5 + 0.5, 0.3, 1.0);
    float maxIter = max(uIterations * lodFactor, 1.0);
    int intMaxIter = int(maxIter);
    
    // Precompute bailout squared
    float bailoutSq = uBailout * uBailout;
    
    float iter = 0.0;
    float zMagSq = 0.0;

    // Unrolled inner loop with early exit
    for (int i = 0; i < 1000; i++) {
        if (i >= intMaxIter) break;
        
        zMagSq = dot(z, z);
        if (zMagSq > bailoutSq) {
            iter = float(i);
            break;
        }
        
        // Optimized complex multiplication: (a+bi)^2 = a^2-b^2 + 2abi
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        iter = float(i);
    }

    // Smooth iteration count for anti-aliasing (reduces banding)
    float smoothIter = iter;
    if (zMagSq > bailoutSq) {
        // Smooth coloring formula
        smoothIter = iter + 1.0 - log2(log2(zMagSq) * 0.5);
    }

    float t = smoothIter / maxIter;
    vec3 color = palette(t, uColorScheme);

    // Branchless alpha calculation for AR mode
    float inside = step(maxIter - 1.0, iter);
    float alpha = mix(1.0, 1.0 - inside, step(0.5, uTransparentBg));

    fragColor = vec4(color, alpha);
}
