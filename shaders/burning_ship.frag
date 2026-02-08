#include <flutter/runtime_effect.glsl>

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
    // Hardcoded solid blue
    fragColor = vec4(0.0, 0.0, 1.0, 1.0);
}
