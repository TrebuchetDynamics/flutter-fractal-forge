#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbrot percolation / random Sierpiński carpet.
// Stochastic Sierpiński construction: the unit square is recursively divided
// into a 3x3 grid; each cell is independently kept with probability p or
// dropped. Same seed gives a reproducible carpet; color encodes the deepest
// subdivision level a point survives.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (used as max subdivision depth)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uProbability;   // 10 (keep probability p in (0,1])
uniform float uSeed;          // 11

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// Deterministic hash in [0,1) for a cell at (lx,ly) on level `level`.
float cellHash(int level, int lx, int ly, float seed) {
  vec2 p = vec2(float(lx), float(ly)) + float(level * 7) + seed * 31.0;
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
  // Map to the unit carpet; uCenter/zoom allow panning into detail.
  vec2 p = uv + vec2(0.5 + uCenter.x, 0.5 + uCenter.y);
  p = clamp(p, 0.0, 1.0 - 1e-6);

  float keep = clamp(uProbability, 0.02, 1.0);
  int maxDepth = int(clamp(uIterations, 3.0, 16.0));

  float level = 0.0;
  int lx = 0, ly = 0;
  bool alive = true;
  float scale = 1.0;
  // Track the 3-adic cell address incrementally.
  for (int d = 0; d < 16; d++) {
    if (d >= maxDepth) break;
    scale *= 3.0;
    // SkSL has no integer '%'; compute cell index via integer division/remainder.
    int cxf = int(floor(p.x * scale));
    int cyf = int(floor(p.y * scale));
    int cx = cxf - 3 * (cxf / 3);
    int cy = cyf - 3 * (cyf / 3);
    // Cell index within the 3x3 grid at this level.
    int cell = cx * 3 + cy;
    float h = cellHash(d, cx, cy, uSeed);
    if (h > keep) { alive = false; break; }
    level += 1.0;
  }

  float t = level / float(maxDepth);
  vec3 color;
  if (alive) {
    color = palette(fract(level * 0.7), uColorScheme);
  } else {
    // Cells dropped earlier are darker; dropped at max depth are dimmest.
    color = palette(fract(level * 0.7), uColorScheme) * (0.25 + 0.75 * (level / float(maxDepth)));
  }
  float alpha = uTransparentBg > 0.5 ? 1.0 : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
