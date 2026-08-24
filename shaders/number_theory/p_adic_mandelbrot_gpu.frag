#include <flutter/runtime_effect.glsl>

precision highp float;

// p-adic Mandelbrot / arithmetic-dynamics annuli view.
// Over the p-adic numbers, filled Julia and Mandelbrot sets of z -> z^2 + c
// are unions of residue-class disks: the tree of p-adic neighborhoods renders
// as nested concentric annuli, quite unlike complex-plane dynamics. We draw
// the p-adic disk tree (radius bounds per residue class) with depth-graded
// shading — honestly named as a p-adic-inspired tree/annuli view.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (tree depth)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uPrime;         // 10 (prime p)
uniform float uMode;          // 11 (0=annuli, 1=residue-class rings)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
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

  float prime = clamp(floor(uPrime + 0.5), 2.0, 7.0);
  int depth = int(clamp(uIterations, 2.0, 8.0));
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 1.0));

  // Radial coordinate plays the role of the p-adic valuation: disks of
  // radius p^-k. Angle partitions into p residue classes per level.
  float r = length(p);
  float theta = atan(p.y, p.x) / 6.28318 + 0.5; // [0,1)

  if (mode == 0) {
    // Annuli: nested disks at radii p^-k with alternating tones.
    float logr = -log(max(r, 1e-9)) / log(prime); // p-adic level ~ valuation
    float lvl = floor(logr);
    float inDisk = step(0.0, logr) * step(logr, depth);
    float frac = fract(logr);
    float ring = smoothstep(0.0, 0.06, frac) * (1.0 - smoothstep(0.94, 1.0, frac));
    // Residue class index at the current level.
    float res = floor(fract(theta * prime) * prime);
    vec3 base = palette(fract((lvl + res * 0.37) / prime * 0.9), uColorScheme);
    vec3 color = base * (0.35 + 0.65 * ring) * (0.25 + 0.75 * inDisk);
    fragColor = vec4(linearToSRGB(color), 1.0);
  } else {
    // Residue-class rings: partition the angle into p^k sectors by depth,
    // each sector graded by its residue chain (tree of p-adic neighborhoods).
    float acc = 0.0;
    float w = 1.0;
    float scaleA = 1.0;
    for (int d = 0; d < 8; d++) {
      if (d >= depth) break;
      scaleA *= prime;
      float res = floor(fract(theta * scaleA) * prime);
      float lvlRes = floor(theta * scaleA) / scaleA;
      acc += res * w;
      w *= 0.55;
    }
    vec3 color = palette(fract(acc), uColorScheme);
    // Radial annulus shading keeps the disk-tree reading.
    float logr = -log(max(r, 1e-9)) / log(prime);
    float inDisk = step(0.0, logr) * step(logr, float(depth));
    color *= 0.3 + 0.7 * inDisk;
    fragColor = vec4(linearToSRGB(color), 1.0);
  }
}
