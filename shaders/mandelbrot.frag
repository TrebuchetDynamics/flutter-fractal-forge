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
    // Simple test: output gradient based on position
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;
    
    // Simple gradient from red to blue
    fragColor = vec4(uv.x, 0.2, uv.y, 1.0);
}
