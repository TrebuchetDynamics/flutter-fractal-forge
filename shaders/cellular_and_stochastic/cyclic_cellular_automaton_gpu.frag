#include <flutter/runtime_effect.glsl>

precision highp float;

// Cyclic cellular automaton for excitable-media spiral waves.
// A cell advances from state s to (s + 1) mod states when at least threshold
// neighbours are already in that next state.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uStates;        // 10
uniform float uThreshold;     // 11

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec3 palette(float t, int scheme) {
  if (scheme == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

float seedState(vec2 cell, int states) {
  return floor(hash12(cell) * float(states));
}

float cyclicCellState(vec2 cell, int steps, int states, int threshold) {
  float state = seedState(cell, states);
  for (int i = 0; i < 96; i++) {
    if (i >= steps) break;
    float nextState = mod(state + 1.0, float(states));
    int count = 0;
    for (int y = -1; y <= 1; y++) {
      for (int x = -1; x <= 1; x++) {
        if (x == 0 && y == 0) continue;
        vec2 n = cell + vec2(float(x), float(y));
        float wave = floor(hash12(n + float(i) * vec2(7.0, 13.0)) * float(states));
        float neighbour = mod(seedState(n, states) + wave + float(i), float(states));
        if (abs(neighbour - nextState) < 0.5) count++;
      }
    }
    if (count >= threshold) state = nextState;
  }
  return state;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(float(uResolution.x), float(uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(uZoom, 1e-6) + uCenter;

  int states = int(clamp(uStates, 3.0, 16.0));
  int threshold = int(clamp(uThreshold, 1.0, 8.0));
  int steps = int(clamp(uIterations + uTime * 0.015, 1.0, 96.0));
  vec2 cell = floor(p * 64.0);
  float state = cyclicCellState(cell, steps, states, threshold);
  float t = fract(state / float(states) + 0.08 * sin(dot(p, vec2(5.0, 7.0))));
  vec3 color = palette(t, int(uColorScheme));

  fragColor = vec4(linearToSRGB(color), 1.0);
}
