#include <flutter/runtime_effect.glsl>

precision highp float;

// Arnoux-Rauzy substitution fractal.
// Canonical substitutions on three letters include:
//   sigma_1: 1 -> 1, 2 -> 21, 3 -> 31
//   sigma_2: 1 -> 12, 2 -> 2, 3 -> 32
//   sigma_3: 1 -> 13, 2 -> 23, 3 -> 3
// This shader renders the balanced prefix-walk projection used for Rauzy
// windows: letters step along the three roots of unity and the directive
// sequence cycles through the three Arnoux-Rauzy substitutions.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uDepth;         // 10

out vec4 fragColor;

const int MAX_STEPS = 180;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.50), vec3(0.50), vec3(1.0), vec3(0.02, 0.32, 0.66));
  if (scheme == 1) return iqPalette(t, vec3(0.48), vec3(0.42), vec3(1.0, 0.8, 0.6), vec3(0.50, 0.20, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.55, 0.50, 0.45), vec3(0.45), vec3(0.7, 0.9, 1.2), vec3(0.05, 0.18, 0.28));
  if (scheme == 3) return vec3(0.35 + 0.65 * t);

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.8 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 basis(int letter) {
  if (letter == 0) return vec2(1.0, 0.0);
  if (letter == 1) return vec2(-0.5, 0.8660254);
  return vec2(-0.5, -0.8660254);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(1e-6, dot(ba, ba)), 0.0, 1.0);
  return length(pa - ba * h);
}

int arLetter(float n) {
  // Balanced 3-letter coding of a torus translation. It gives a stable,
  // non-periodic Arnoux-Rauzy prefix without storing a word on the GPU.
  vec3 hit = fract((n + 1.0) * vec3(0.414213562, 0.569840291, 0.754877666));
  if (hit.x > hit.y && hit.x > hit.z) return 0;
  if (hit.y > hit.z) return 1;
  return 2;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = (uv / max(uZoom, 1e-6) + uCenter) * 1.55;

  float depth = clamp(uDepth, 3.0, 18.0);
  int steps = int(clamp(max(uIterations, depth * 10.0), 36.0, float(MAX_STEPS)));
  float stride = 2.15 / sqrt(float(steps));
  float width = (0.010 + 0.018 / max(uZoom, 1.0)) * clamp(uBailout / 4.0, 0.55, 1.8);

  vec2 pos = vec2(-0.18, 0.03);
  float d = 1e6;
  float letterMix = 0.0;

  for (int i = 0; i < MAX_STEPS; i++) {
    if (i >= steps) break;

    int letter = arLetter(float(i));
    int directive = i - (i / 3) * 3;
    float turn = 0.22 * float(directive - 1);
    vec2 step = basis(letter);
    vec2 warped = vec2(
      step.x * cos(turn) - step.y * sin(turn),
      step.x * sin(turn) + step.y * cos(turn)
    );
    vec2 next = pos + stride * warped;

    d = min(d, sdSegment(p, pos, next));
    pos = next;
    letterMix += float(letter) + 1.0;
  }

  float ink = smoothstep(width, 0.0, d);
  if (ink <= 0.001 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  float glow = smoothstep(width * 6.0, 0.0, d) * 0.28;
  float t = fract(letterMix / max(1.0, float(steps)) * 0.21 + 0.35 * ink);
  vec3 curve = getPaletteColor(t, int(uColorScheme));
  vec3 background = vec3(0.010, 0.013, 0.024) + glow * vec3(0.08, 0.10, 0.16);
  vec3 color = mix(background, curve, ink);

  fragColor = vec4(linearToSRGB(color), 1.0);
}
