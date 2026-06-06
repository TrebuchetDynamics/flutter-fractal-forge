#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

float hash21(vec2 p) {
  p = fract(p * vec2(127.1, 311.7));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

ivec2 stepDir(int d) {
  if (d == 0) return ivec2(1, 0);
  if (d == 1) return ivec2(0, 1);
  if (d == 2) return ivec2(-1, 0);
  return ivec2(0, -1);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  ivec2 query = ivec2(floor(p * 64.0));

  ivec2 ant = ivec2(0, 0);
  int dir = 0;
  int machineState = 0;

  float visits = 0.0;
  float lastCellColor = 0.0;
  float lastMachineState = 0.0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    // Stateless approximation of grid cell color based on visit context.
    float cellColor = step(0.5, hash21(vec2(ant) + float(i) * 0.013));

    // 2-state 2-color turmite rule table:
    // (state0,color0)->R,state1,color1
    // (state0,color1)->L,state0,color0
    // (state1,color0)->L,state0,color1
    // (state1,color1)->R,state1,color0
    bool turnRight = (machineState == 0 && cellColor < 0.5) ||
                     (machineState == 1 && cellColor > 0.5);

    if (turnRight) dir = (dir + 1) - ((dir + 1) / 4) * 4;
    else dir = (dir + 3) - ((dir + 3) / 4) * 4;

    float newCellColor;
    if (machineState == 0) {
      newCellColor = 1.0 - cellColor;
      machineState = (cellColor < 0.5) ? 1 : 0;
    } else {
      newCellColor = 1.0 - cellColor;
      machineState = (cellColor < 0.5) ? 0 : 1;
    }

    if (all(equal(ant, query))) {
      visits += 1.0;
      lastCellColor = newCellColor;
      lastMachineState = float(machineState);
    }

    ant += stepDir(dir);
    ant = ivec2(
      int(clamp(float(ant.x), -256.0, 256.0)),
      int(clamp(float(ant.y), -256.0, 256.0))
    );
  }

  float stateMix = 0.5 * lastCellColor + 0.5 * lastMachineState;
  float energy = min(1.0, visits / 6.0);
  float t = fract(0.15 + stateMix * 0.7 + energy * 0.35 + uTime * 0.0001);

  vec3 base = getPaletteColor(t, int(uColorScheme));
  vec3 color = base * (0.25 + 0.95 * energy);

  if (visits < 0.5) {
    if (uTransparentBg > 0.5) {
      fragColor = vec4(0.0);
      return;
    }
    fragColor = vec4(linearToSRGB(vec3(0.015, 0.02, 0.025)), 1.0);
    return;
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
