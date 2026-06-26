#include <flutter/runtime_effect.glsl>

precision highp float;

// Greenberg-Hastings excitable cellular automaton.
// Resting cells excite when enough neighbours are excited; excited cells become
// refractory; refractory cells decay back to rest after refractoryPeriod.

uniform float uTime;              // 0
uniform vec2  uResolution;        // 1-2
uniform vec2  uCenter;            // 3-4
uniform float uZoom;              // 5
uniform float uIterations;        // 6
uniform float uBailout;           // 7
uniform float uColorScheme;       // 8
uniform float uTransparentBg;     // 9
uniform float uThreshold;         // 10
uniform float uRefractoryPeriod;  // 11

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

float seedState(vec2 cell, int refractoryPeriod) {
  float r = hash12(cell);
  if (r < 0.08) return 1.0;
  if (r < 0.24) return 2.0 + floor(hash12(cell + 17.0) * float(refractoryPeriod));
  return 0.0;
}

float greenbergHastingsState(vec2 cell, int steps, int threshold, int refractoryPeriod) {
  float state = seedState(cell, refractoryPeriod);
  for (int i = 0; i < 96; i++) {
    if (i >= steps) break;
    int excitedNeighbours = 0;
    for (int y = -1; y <= 1; y++) {
      for (int x = -1; x <= 1; x++) {
        if (x == 0 && y == 0) continue;
        vec2 n = cell + vec2(float(x), float(y));
        float phase = mod(seedState(n, refractoryPeriod) + floor(hash12(n + float(i) * 11.0) * 3.0) + float(i), float(refractoryPeriod + 2));
        if (phase >= 0.5 && phase < 1.5) excitedNeighbours++;
      }
    }

    if (state < 0.5) {
      if (excitedNeighbours >= threshold) state = 1.0;
    } else if (state < 1.5) {
      state = 2.0;
    } else {
      state += 1.0;
      if (state > float(refractoryPeriod + 1)) state = 0.0;
    }
  }
  return state;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(float(uResolution.x), float(uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(uZoom, 1e-6) + uCenter;

  int threshold = int(clamp(uThreshold, 1.0, 8.0));
  int refractoryPeriod = int(clamp(uRefractoryPeriod, 2.0, 16.0));
  int steps = int(clamp(uIterations + uTime * 0.015, 1.0, 96.0));
  vec2 cell = floor(p * 70.0);
  float state = greenbergHastingsState(cell, steps, threshold, refractoryPeriod);

  vec3 color = vec3(0.015, 0.018, 0.03);
  if (state >= 0.5 && state < 1.5) {
    color = vec3(1.0, 0.82, 0.25);
  } else if (state >= 1.5) {
    float t = (state - 2.0) / max(1.0, float(refractoryPeriod));
    color = palette(0.55 + 0.35 * t, int(uColorScheme)) * (0.35 + 0.5 * t);
  }

  if (length(color) < 0.02 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }
  fragColor = vec4(linearToSRGB(color), 1.0);
}
