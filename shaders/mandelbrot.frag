#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

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

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    
    // DIAGNOSTIC MODE: Show different colors based on what works
    
    // If we see this color, the shader is running
    vec3 baseColor = vec3(0.0);
    
    // Check if fragCoord is valid (should be > 0)
    if (fragCoord.x > 0.0 && fragCoord.y > 0.0) {
        baseColor.r = 0.2; // Red tint = fragCoord works
    }
    
    // Check if uResolution is valid
    if (uResolution.x > 1.0 && uResolution.y > 1.0) {
        baseColor.g = 0.2; // Green tint = uResolution works
        
        // Try to use normalized coordinates
        vec2 uv = fragCoord / uResolution;
        
        // Make a gradient to prove UV coords work
        baseColor.r += uv.x * 0.8;
        baseColor.b += uv.y * 0.8;
    } else {
        // Resolution is invalid - make it bright magenta
        baseColor = vec3(1.0, 0.0, 1.0);
    }
    
    // Check if zoom uniform is being passed
    if (uZoom > 0.0) {
        baseColor.g += 0.3; // More green = zoom is valid
    }
    
    // Flash based on time to show animation works
    float pulse = 0.5 + 0.5 * sin(uTime * 0.001);
    baseColor *= (0.8 + 0.2 * pulse);
    
    fragColor = vec4(baseColor, 1.0);
}
