#include <flutter/runtime_effect.glsl>

precision highp float;

// Fractal dual substitution tiling approximation.
// A Pisot-style expanding substitution is viewed in contracting/projected
// space; repeated dual substitutions draw self-affine tile boundaries.

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

float tileLine(vec2 p) {
  vec2 g = abs(fract(p) - 0.5);
  return min(g.x, g.y);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(uZoom, 1e-6) + uCenter;

  int depth = int(clamp(uDepth, 3.0, 14.0));
  vec2 q = p * 2.0;
  float boundary = 1.0;
  float cellId = 0.0;

  for (int i = 0; i < 14; i++) {
    if (i >= depth) break;
    float line = tileLine(q);
    boundary = min(boundary, line / pow(1.35, float(i)));
    vec2 id = floor(q);
    cellId += fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453) / float(i + 1);

    // Contracting-space dual substitution: anisotropic Pisot-like scaling,
    // then rotate to expose distinct prototile boundary directions.
    q = rot(1.2566371) * (mat2(1.32, 0.38, -0.22, 0.86) * q);
    q += vec2(0.31, -0.17);
  }

  float ink = smoothstep(0.018, 0.0, boundary);
  if (ink <= 0.001 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  vec3 a = vec3(0.08, 0.10, 0.18);
  vec3 b = 0.55 + 0.45 * cos(6.28318 * (cellId + vec3(0.0, 0.33, 0.67)));
  vec3 color = mix(a, b, 0.25 + 0.75 * ink);
  fragColor = vec4(linearToSRGB(color), 1.0);
}
