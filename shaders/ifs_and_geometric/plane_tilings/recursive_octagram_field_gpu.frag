#include <flutter/runtime_effect.glsl>

precision highp float;

// Original eight-fold recursive reflection field. The construction uses a
// dihedral fold and similarity recursion rather than raymarched box geometry.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uFoldScale;
uniform float uRotationRate;

out vec4 fragColor;

const float PI = 3.141592653589793;
const float TAU = 6.283185307179586;

mat2 rotate2d(float a) {
  float c = cos(a), s = sin(a);
  return mat2(c, -s, s, c);
}

vec2 foldOctant(vec2 p) {
  p = abs(p);
  vec2 diagonal = normalize(vec2(1.0, -1.0));
  p -= 2.0 * min(0.0, dot(p, diagonal)) * diagonal;
  return p;
}

float octagramDistance(vec2 p, float radius) {
  float a = atan(p.y, p.x);
  float r = length(p);
  float boundary = radius * mix(0.44, 1.0, pow(abs(cos(4.0 * a)), 0.72));
  return abs(r - boundary);
}

vec3 palette(float t, float scheme) {
  vec3 phase = vec3(0.0, 0.34, 0.67) + fract(scheme * 0.113);
  return 0.5 + 0.5 * cos(TAU * (t + phase));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float shortSide = max(1.0, min(uResolution.x, uResolution.y));
  vec2 p = (fragCoord - 0.5 * uResolution) / shortSide;
  p = p / max(uZoom, 0.0001) + uCenter;

  int depth = int(clamp(floor(uIterations + 0.5), 1.0, 10.0));
  float scale = clamp(uFoldScale, 1.45, 2.6);
  vec2 q = rotate2d(0.10 * uTime * uRotationRate) * p;
  float lineDistance = 1e4;
  float orbit = 1e4;
  float inverseScale = 1.0;

  for (int level = 0; level < 10; level++) {
    if (level >= depth) break;
    q = foldOctant(q);
    float localStar = octagramDistance(q, 0.34);
    lineDistance = min(lineDistance, localStar * inverseScale);
    orbit = min(orbit, abs(q.x - q.y) * inverseScale);
    q = rotate2d(PI * 0.125 + 0.035 * sin(uTime * uRotationRate)) * q;
    q = q * scale - vec2(0.52, 0.18);
    inverseScale /= scale;
  }

  float pixel = 1.25 / shortSide / max(uZoom, 0.0001);
  float filaments = exp(-lineDistance / max(pixel * 2.2, 0.0015));
  float mirrors = exp(-orbit / max(pixel * 1.2, 0.001));
  float cells = 0.5 + 0.5 * cos(18.0 * log(1.0 + length(p)) - 0.65 * uTime);
  vec3 color = palette(cells + 0.16 * float(depth), uColorScheme);
  color *= 0.08 + 1.2 * filaments;
  color += palette(0.25 + cells, uColorScheme + 3.0) * 0.38 * mirrors;
  color *= smoothstep(0.92, 0.16, length(p));
  color = 1.0 - exp(-1.3 * color);
  float alpha = uTransparentBg > 0.5 ? clamp(max(max(color.r, color.g), color.b) * 1.4, 0.0, 1.0) : 1.0;
  fragColor = vec4(color, alpha);
}
