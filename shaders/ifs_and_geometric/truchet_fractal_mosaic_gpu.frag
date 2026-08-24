#include <flutter/runtime_effect.glsl>

precision highp float;

// Truchet-tile fractal mosaic (generalized Smith/Truchet curves).
// Subdivide the plane into a grid; a per-cell hash picks one of the two
// classic diagonal arc orientations (Smith's variation), optionally with
// hinged/recursive subdivision that nests smaller Truchet lattices inside
// each cell for a fractal maze look.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (used as recursion depth)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uTileScale;     // 10 (tiles across the viewport)
uniform float uSeed;          // 11
uniform float uThickness;     // 12
uniform float uMode;          // 13 (0=arcs, 1=hinged/recursive)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash21(vec2 p, float seed) {
  p = p + seed * 17.17;
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 palette(float t, float s) {
  int scheme = int(clamp(floor(s + 0.5), 0.0, 63.0));
  if (scheme == 0) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.4)), 0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  if (scheme == 1) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)), 0.5 + 0.5 * cos(6.28318 * (t + 0.3)), 0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  if (scheme == 2) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.33)), 0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float sf = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * sf + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * sf + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * sf + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (sf + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv / max(uZoom, 0.0001) + uCenter;

  float tiles = clamp(uTileScale, 2.0, 64.0);
  float seed = uSeed;
  float thick = clamp(uThickness, 0.02, 0.5);
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 1.0));
  int depth = int(clamp(uIterations, 1.0, 6.0));

  // Base grid coordinates.
  vec2 g = p * tiles;
  vec2 cell = floor(g);
  vec2 f = fract(g);

  // Orientation from per-cell hash.
  float h = hash21(cell, seed);
  bool flip = h > 0.5;

  // Track the finest cell for hinged/recursive mode.
  float levelScale = 1.0;
  vec2 finCell = cell;
  float finH = h;
  bool finFlip = flip;
  if (mode == 1) {
    // Recursive subdivision: at each level the tile lattice refines 2x and a
    // new hash chooses which quadrant hosts the nested maze.
    for (int d = 0; d < 6; d++) {
      if (d >= depth) break;
      levelScale *= 2.0;
      vec2 gg = p * tiles * levelScale;
      vec2 c2 = floor(gg);
      vec2 f2 = fract(gg);
      // Keep only the quadrant chain that keeps nesting (hash-selected).
      float h2 = hash21(c2, seed + float(d) * 3.7);
      if (h2 > 0.6) {
        finCell = c2;
        finH = h2;
        finFlip = h2 > 0.8;
        f = f2;
      }
    }
  }

  // Distance to the two classic quarter-circle arcs of a Truchet tile.
  // Tile-local coordinates in [0,1]^2; arcs centered at two opposite corners.
  vec2 q = finFlip ? vec2(1.0 - f.x, f.y) : f;
  // Arc A: center (0,0) radius 0.5; Arc B: center (1,1) radius 0.5.
  float dA = abs(length(q - vec2(0.0, 0.0)) - 0.5);
  float dB = abs(length(q - vec2(1.0, 1.0)) - 0.5);
  // Only the quarter facing the tile interior matters; mask the outer halves.
  float maskA = step(0.0, q.x) * step(0.0, q.y) * step(q.x + q.y, 1.5) * step(-0.5, -(q.x + q.y - 1.5));
  float inA = (q.x < 0.5 && q.y < 0.5) || (q.x + q.y > 1.0) ? 1.0 : 0.0;
  float inB = (q.x > 0.5 && q.y > 0.5) || (q.x + q.y < 1.0) ? 1.0 : 0.0;
  float dArc = min(dA * inA, dB * inB);
  if (inA < 0.5 && inB < 0.5) dArc = 1.0;

  float lineWidth = thick * 0.25;
  float line = 1.0 - smoothstep(0.0, lineWidth, dArc);

  // Base mosaic tone varies by cell hash for a patchwork feel.
  float cellTone = 0.25 + 0.5 * hash21(finCell, seed + 5.0);
  vec3 base = palette(fract(finH + cellTone * 0.5), uColorScheme) * (0.35 + 0.4 * cellTone);
  vec3 ink = palette(fract(finH * 7.0 + 0.35), uColorScheme);
  vec3 color = mix(base, ink, line);

  float alpha = uTransparentBg > 0.5 ? max(line, 0.35) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
