#include <flutter/runtime_effect.glsl>

precision highp float;

// Rep-tile / irreptile tiling explorer.
// A rep-tile is a shape that tiles a larger copy of itself. We render the
// recursive subdivision of classic rep-tiles (chair and sphinx families) as a
// distance-to-boundary field with depth-graded coloring: at each level the
// tile splits into 4 (chair) or 4 (sphinx) scaled copies, and the smallest
// enclosing sub-tile determines the shading depth.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (subdivision depth)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uShape;         // 10 (0=chair, 1=sphinx)
uniform float uLineWeight;    // 11

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// Signed distance to a unit chair rep-tile centered at origin (approx).
float chairSDF(vec2 p) {
  // Chair: union of a 1.2x1.2 square minus two corner notches.
  vec2 q = abs(p);
  float box = max(q.x - 0.6, q.y - 0.6);
  // Notch cut at the top-right corner (classic chair silhouette).
  float notch = max(q.x - 0.2 - 0.4, 0.2 - q.y - 0.25);
  return max(box, -notch);
}

// Signed distance to a unit sphinx rep-tile (approx hexiamond silhouette).
float sphinxF(vec2 p) {
  // Approximate the sphinx (a hexiamond) as a pentagon-ish shape.
  float d = 1e5;
  // Body: skewed triangle pair.
  vec2 a = p - vec2(0.0, -0.1);
  float t1 = max(abs(a.x) * 0.9 + abs(a.y) * 0.55 - 0.5, -a.y + 0.25);
  float t2 = max(abs(a.x) * 0.7 + abs(a.y + 0.35) * 1.1 - 0.55, a.y + 0.6);
  d = min(t1, t2);
  return d;
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

float hash21(vec2 p, float seed) {
  p = p + seed * 7.77;
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv / max(uZoom, 0.0001) + uCenter;

  int shape = int(clamp(floor(uShape + 0.5), 0.0, 1.0));
  int depth = int(clamp(uIterations, 1.0, 6.0));
  float lw = clamp(uLineWeight, 0.01, 0.2);

  // Track which recursion level's cell contains p.
  float scale = 1.0;
  vec2 q = p;
  int level = 0;
  float idSum = 0.0;
  for (int d = 0; d < 6; d++) {
    if (d >= depth) break;
    scale *= 2.0;
    // Chair/sphinx split into 4 copies at half size; find the quadrant copy.
    vec2 c = floor(q * 2.0);
    idSum += hash21(c, 0.0) * pow(0.5, float(d));
    q = fract(q * 2.0) - 0.5;
    level = d + 1;
  }

  // Distance to the tile boundary at the finest level.
  float dist = shape == 0 ? chairSDF(q) : sphinxF(q);
  float edge = 1.0 - smoothstep(0.0, lw, abs(dist));

  // Depth-graded fill: shallower levels lighter, deeper levels saturated.
  float depthT = float(level) / 6.0;
  vec3 base = palette(fract(depthT * 1.6 + idSum), uColorScheme);
  vec3 ink = vec3(0.06);
  vec3 color = mix(base * (0.55 + 0.45 * depthT), ink, edge);

  float alpha = uTransparentBg > 0.5 ? max(edge, 0.4) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
