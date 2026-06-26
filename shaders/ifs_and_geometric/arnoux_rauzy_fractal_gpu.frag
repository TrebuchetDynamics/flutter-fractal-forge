#include <flutter/runtime_effect.glsl>

precision highp float;

// Arnoux-Rauzy substitution fractal.
// Canonical substitutions on three letters include:
//   sigma_1: 1 -> 1, 2 -> 21, 3 -> 31
//   sigma_2: 1 -> 12, 2 -> 2, 3 -> 32
//   sigma_3: 1 -> 13, 2 -> 23, 3 -> 3
// This shader renders a projected prefix-walk / address-space approximation.

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

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

mat2 rot(float a) {
  float c = cos(a), s = sin(a);
  return mat2(c, -s, s, c);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(1e-6, dot(ba, ba)), 0.0, 1.0);
  return length(pa - ba * h);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(uZoom, 1e-6) + uCenter;

  int depth = int(clamp(uDepth, 3.0, 18.0));
  vec2 pos = vec2(0.0);
  vec2 dir = vec2(0.09, 0.0);
  float d = 1e6;
  float letter = 0.0;

  for (int i = 0; i < 18; i++) {
    if (i >= depth) break;
    int sigma = i - (i / 3) * 3;
    vec2 turn = sigma == 0 ? vec2(1.0, 0.0) : (sigma == 1 ? vec2(-0.5, 0.8660254) : vec2(-0.5, -0.8660254));
    vec2 next = pos + dir + 0.055 * turn;
    d = min(d, sdSegment(p, pos, next));
    pos = next;
    dir = rot(2.0943951 + 0.17 * float(sigma)) * dir * 0.92;
    letter = float(sigma);
  }

  float ink = smoothstep(0.014, 0.0, d);
  if (ink <= 0.001 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  vec3 base = mix(vec3(0.12, 0.18, 0.42), vec3(0.95, 0.72, 0.28), letter / 2.0);
  vec3 color = mix(vec3(0.015, 0.018, 0.030), base, ink);
  fragColor = vec4(linearToSRGB(color), 1.0);
}
