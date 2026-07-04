#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uPSides;
uniform float uQMeet;

out vec4 fragColor;

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

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  if (s < 1.0) return iqPalette(t, vec3(0.50), vec3(0.50), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s < 2.0) return iqPalette(t, vec3(0.42, 0.25, 0.12), vec3(0.42, 0.30, 0.16), vec3(1.0, 0.85, 0.5), vec3(0.0, 0.15, 0.32));
  if (s < 3.0) return iqPalette(t, vec3(0.10, 0.18, 0.28), vec3(0.25, 0.35, 0.45), vec3(0.8, 0.9, 1.1), vec3(0.45, 0.18, 0.02));
  return iqPalette(t, vec3(0.52), vec3(0.48), vec3(1.0, 0.75, 0.55), vec3(fract(s * 0.21), 0.34, 0.67));
}

float lineMask(float d, float width) {
  return 1.0 - smoothstep(width, width * 1.8, abs(d));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scale;
  vec2 z = uv * 1.9 / max(uZoom, 0.0001) + uCenter;

  float r = length(z);
  if (r >= 0.998) {
    float edge = 1.0 - smoothstep(0.998, 1.02, r);
    vec3 bg = vec3(0.006, 0.007, 0.014);
    float alpha = uTransparentBg > 0.5 ? edge : 1.0;
    fragColor = vec4(linearToSRGB(bg), alpha);
    return;
  }

  float p = floor(clamp(uPSides, 3.0, 12.0) + 0.5);
  float q = floor(clamp(uQMeet, 3.0, 9.0) + 0.5);
  float depth = clamp(uIterations * 0.25, 3.0, 18.0);

  // Poincare radial distance: Euclidean radius maps to infinite hyperbolic
  // distance as r approaches the disk boundary.
  float h = log((1.0 + r) / max(1.0 - r, 1e-5));
  float theta = atan(z.y, z.x);

  // Hyperbolic rings get closer in Euclidean space near the edge.
  float ringPitch = 0.55 + 2.0 / (p + q);
  float ringCoord = h / ringPitch;
  float ringId = floor(ringCoord);
  float ringLine = lineMask(fract(ringCoord) - 0.5, 0.035 + 0.015 * r);

  // Angular sectors rotate per ring to create Escher-like interlocking tiles.
  float sectors = p + mod(ringId, max(q, 1.0));
  float aCoord = theta / 6.2831853 * sectors + 0.5 * mod(ringId, 2.0);
  float spokeLine = lineMask(fract(aCoord) - 0.5, 0.028 + 0.02 * r);

  // Curved arcs: offset angle by hyperbolic radius so edges bow inward.
  float curveCoord = theta / 6.2831853 * p + h * (q - 2.0) * 0.18;
  float curveLine = lineMask(fract(curveCoord) - 0.5, 0.024 + 0.016 * r);

  float tile = mod(ringId + floor(aCoord), 2.0);
  float t = fract(ringId * 0.071 + floor(aCoord) * 0.113 + tile * 0.25 + uTime * 0.00002);
  vec3 colorA = palette(t, uColorScheme);
  vec3 colorB = palette(t + 0.35, uColorScheme + 1.0);
  vec3 color = mix(colorA, colorB, tile) * (0.42 + 0.42 * (1.0 - r));

  float lines = max(max(ringLine, spokeLine), curveLine);
  color = mix(color, vec3(0.92, 0.88, 0.74), lines * 0.9);
  color *= 1.0 - smoothstep(0.92, 0.998, r) * 0.45;

  // Outer disk boundary.
  color += vec3(0.5, 0.7, 1.0) * lineMask(r - 0.985, 0.006) * 0.5;

  fragColor = vec4(linearToSRGB(color), 1.0);
}
