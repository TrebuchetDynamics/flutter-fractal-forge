#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform vec2 uJuliaC;
uniform float uTransparentBg;

out vec4 fragColor;

// Branchless palette selection
vec3 palette(float t, float scheme) {
    vec3 fire = vec3(0.2 + 0.8 * t, 0.1 + 0.3 * t, 0.05 + 0.2 * t);
    vec3 ocean = vec3(0.05 + 0.3 * t, 0.2 + 0.7 * t, 0.4 + 0.5 * t);
    vec3 psychedelic = vec3(
        0.5 + 0.5 * sin(6.2831 * t + uTime * 0.2),
        0.5 + 0.5 * sin(6.2831 * t + 2.0),
        0.5 + 0.5 * sin(6.2831 * t + 4.0)
    );
    vec3 gray = vec3(t);
    
    float s0 = step(0.5, scheme);
    float s1 = step(1.5, scheme);
    float s2 = step(2.5, scheme);
    
    vec3 result = fire;
    result = mix(result, ocean, s0 * (1.0 - s1));
    result = mix(result, psychedelic, s1 * (1.0 - s2));
    result = mix(result, gray, s2);
    
    return result;
}

void main() {
    vec2 uv = (FlutterFragCoord().xy - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    
    // Precompute constants
    float invZoom = 1.0 / max(uZoom, 0.0001);
    vec2 z = uv * invZoom + uCenter;
    vec2 c = uJuliaC;
    
    // LOD based on zoom level
    float lodFactor = clamp(log2(uZoom + 1.0) * 0.5 + 0.5, 0.3, 1.0);
    float maxIter = max(uIterations * lodFactor, 1.0);
    int intMaxIter = int(maxIter);
    
    // Precompute bailout squared
    float bailoutSq = uBailout * uBailout;
    
    float iter = 0.0;
    float zMagSq = 0.0;

    for (int i = 0; i < 1000; i++) {
        if (i >= intMaxIter) break;
        
        zMagSq = dot(z, z);
        if (zMagSq > bailoutSq) {
            iter = float(i);
            break;
        }
        
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        iter = float(i);
    }

    // Smooth iteration count
    float smoothIter = iter;
    if (zMagSq > bailoutSq) {
        smoothIter = iter + 1.0 - log2(log2(zMagSq) * 0.5);
    }

    float t = smoothIter / maxIter;
    vec3 color = palette(t, uColorScheme);

    // Branchless alpha
    float inside = step(maxIter - 1.0, iter);
    float alpha = mix(1.0, 1.0 - inside, step(0.5, uTransparentBg));

    fragColor = vec4(color, alpha);
}
