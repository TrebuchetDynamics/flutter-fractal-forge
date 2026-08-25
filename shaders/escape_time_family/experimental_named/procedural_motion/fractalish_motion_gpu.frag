#include <flutter/runtime_effect.glsl>

precision highp float;

// Original procedural motion study inspired by the structural language of
// keyframed generative animation: stable composition, smoothly interpolated
// parameters, radial repetition, recursive frames, and domain-warped layers.
// No diffusion model, LoRA, prompt text, or third-party image is used.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uMotif;         // 10: 0 web, 1 sigil, 2 cards, 3 aurora, 4 morph
uniform float uSymmetry;      // 11
uniform float uDetail;        // 12
uniform float uWarp;          // 13
uniform float uMotion;        // 14
uniform float uPhase;         // 15
uniform float uPaletteShift;  // 16

out vec4 fragColor;

const float PI = 3.14159265358979323846;
const float TAU = 6.28318530717958647692;

mat2 rotate2d(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  float a = hash21(i);
  float b = hash21(i + vec2(1.0, 0.0));
  float c = hash21(i + vec2(0.0, 1.0));
  float d = hash21(i + vec2(1.0, 1.0));
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  mat2 turn = rotate2d(0.57);
  for (int i = 0; i < 5; i++) {
    value += amplitude * valueNoise(p);
    p = turn * p * 2.03 + vec2(7.1, 3.7);
    amplitude *= 0.5;
  }
  return value;
}

float sdBox(vec2 p, vec2 halfSize) {
  vec2 d = abs(p) - halfSize;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float lineGlow(float distanceValue, float width, float halo) {
  float core = 1.0 - smoothstep(width, width * 2.0, distanceValue);
  float glow = exp(-distanceValue * halo);
  return max(core, glow * 0.42);
}

vec3 spectralPalette(float phase, float scheme) {
  float s = floor(clamp(scheme, 0.0, 63.0));
  vec3 offset = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 1.0)) * 43758.5453);
  vec3 frequency = 0.85 + 0.35 * sin(vec3(0.7, 1.1, 1.5) * (s * 0.13 + 0.4));
  return clamp(
    0.48 + 0.52 * cos(TAU * (frequency * phase + offset)),
    0.0,
    1.0
  );
}

float orbitTexture(vec2 p, float detail) {
  vec2 c = p * 0.62 + vec2(-0.34, 0.0);
  vec2 z = vec2(0.0);
  float trap = 10.0;
  float escapedAt = 0.0;
  int limit = int(clamp(floor(uIterations + 0.5), 18.0, 54.0));
  float escapeLimit = max(4.0, uBailout * uBailout);
  for (int i = 0; i < 54; i++) {
    if (i >= limit) break;
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    trap = min(trap, abs(length(z) - 0.72));
    if (dot(z, z) > escapeLimit) {
      escapedAt = float(i) / float(limit);
      break;
    }
  }
  return clamp(exp(-trap * (16.0 + detail * 2.5)) * 0.7 + escapedAt * 0.5, 0.0, 1.0);
}

vec3 spiderWebColor(vec2 p, float t, float symmetry, float detail, float warp, float scheme) {
  vec2 q = rotate2d(0.08 * t) * p;
  q += warp * 0.025 * vec2(sin(q.y * 3.0 + t * 0.12), cos(q.x * 3.0 - t * 0.10));
  float radius = length(q);
  float angle = atan(q.y, q.x);
  float sectors = floor(clamp(symmetry, 3.0, 12.0));
  float sectorAngle = TAU / sectors;
  float folded = abs(mod(angle + 0.5 * sectorAngle, sectorAngle) - 0.5 * sectorAngle);

  float spokeDistance = radius * sin(folded);
  float spokes = lineGlow(abs(spokeDistance), 0.006, 28.0);
  float logRadius = log(max(radius, 0.025));
  float ringsPhase = fract(logRadius * (1.8 + detail * 0.16) - t * 0.035);
  float ringDistance = min(ringsPhase, 1.0 - ringsPhase) * radius;
  float rings = lineGlow(ringDistance, 0.006, 32.0) * smoothstep(0.08, 0.95, radius);

  // Analytic spider silhouette: two body ellipses and folded leg curves.
  vec2 bodyQ = rotate2d(-0.12 * sin(t * 0.3)) * q;
  float abdomen = 1.0 - smoothstep(0.92, 1.08, length((bodyQ - vec2(0.0, 0.075)) / vec2(0.14, 0.21)));
  float head = 1.0 - smoothstep(0.90, 1.10, length((bodyQ + vec2(0.0, 0.105)) / vec2(0.09, 0.10)));
  float legCurve = abs(folded - (0.13 + 0.22 * radius + 0.025 * sin(radius * 22.0 - t)));
  float legs = lineGlow(legCurve, 0.012, 24.0) * smoothstep(0.10, 0.58, radius) * (1.0 - smoothstep(0.72, 1.05, radius));
  float body = max(max(abdomen, head), legs);

  float eyeX = abs(bodyQ.x) - 0.032;
  float eyes = exp(-length(vec2(eyeX, bodyQ.y + 0.13)) * 120.0) * head;
  float recursive = orbitTexture(q * (1.0 + 0.08 * detail), detail);
  float structure = clamp(max(spokes * 0.72, rings * 0.82) + body + recursive * 0.34, 0.0, 1.0);
  vec3 base = vec3(0.008, 0.004, 0.018) + 0.05 * spectralPalette(radius * 0.18, scheme + 7.0);
  vec3 web = spectralPalette(angle / TAU + radius * 0.26 + 0.03 * t, scheme);
  vec3 color = mix(base, web, structure);
  color += eyes * vec3(0.7, 0.95, 1.0);
  return color;
}

vec3 arcaneSigilColor(vec2 p, float t, float symmetry, float detail, float warp, float scheme) {
  vec2 q = rotate2d(-0.05 * t) * p;
  q += warp * 0.018 * vec2(sin(q.y * 4.0 + t * 0.09), cos(q.x * 4.0 - t * 0.07));
  float radius = length(q);
  float angle = atan(q.y, q.x);
  float sectors = floor(clamp(symmetry, 3.0, 12.0));
  float folded = abs(mod(angle + PI / sectors, TAU / sectors) - PI / sectors);

  float ringA = lineGlow(abs(radius - 0.35), 0.008, 28.0);
  float ringB = lineGlow(abs(radius - 0.62 - 0.025 * sin(t * 0.4)), 0.006, 32.0);
  float starRadius = 0.44 + 0.17 * cos(folded * sectors * 2.0 + 0.16 * t);
  float star = lineGlow(abs(radius - starRadius), 0.008, 27.0);
  float spokes = lineGlow(abs(radius * sin(folded)), 0.005, 38.0);

  float glyphGrid = fract(angle / TAU * sectors + log(max(radius, 0.04)) * (2.0 + detail * 0.22));
  float glyph = 1.0 - smoothstep(0.06, 0.16, min(glyphGrid, 1.0 - glyphGrid));
  glyph *= smoothstep(0.20, 0.28, radius) * (1.0 - smoothstep(0.72, 0.82, radius));

  vec2 recursiveQ = fract((q + 0.5) * (2.0 + floor(detail * 0.45))) - 0.5;
  float smallRing = lineGlow(abs(length(recursiveQ) - 0.13), 0.008, 32.0);
  float field = clamp(ringA + ringB + star + spokes * 0.5 + glyph * 0.8 + smallRing * 0.35, 0.0, 1.0);
  field = max(field, orbitTexture(q * 0.8, detail) * 0.3);

  vec3 base = vec3(0.012, 0.008, 0.035);
  vec3 ink = spectralPalette(radius * 0.45 + angle / TAU + 0.025 * t, scheme + 13.0);
  vec3 color = mix(base, ink, field);
  color += pow(field, 4.0) * vec3(0.35, 0.2, 0.55);
  return color;
}

vec3 recursiveCardsColor(vec2 p, float t, float symmetry, float detail, float warp, float scheme) {
  vec2 q = rotate2d(0.025 * sin(t * 0.17)) * p;
  q += (fbm(q * 2.2 + t * 0.015) - 0.5) * 0.035 * warp;
  float outerFrame = max(
    lineGlow(abs(sdBox(q, vec2(0.42, 0.70))), 0.010, 30.0),
    lineGlow(abs(sdBox(q, vec2(0.36, 0.62))), 0.007, 36.0)
  );
  float centerRadius = length(q);
  float centerRays = 0.5 + 0.5 * cos(atan(q.y, q.x) * floor(symmetry * 2.0) - t * 0.05);
  float centerSeal = lineGlow(abs(centerRadius - 0.16), 0.009, 34.0) * smoothstep(0.28, 0.72, centerRays);
  float frames = outerFrame;
  float symbols = centerSeal;
  vec2 level = q;
  for (int i = 0; i < 5; i++) {
    vec2 tile = fract(level + 0.5) - 0.5;
    float card = abs(sdBox(tile, vec2(0.31, 0.43)));
    frames = max(frames, lineGlow(card, 0.009, 34.0) / (1.0 + float(i) * 0.18));
    float sun = lineGlow(abs(length(tile) - 0.095), 0.008, 36.0);
    float rays = 0.5 + 0.5 * cos(atan(tile.y, tile.x) * (8.0 + 2.0 * mod(float(i), 3.0)) + t * 0.08);
    symbols = max(symbols, sun * smoothstep(0.35, 0.75, rays));
    level = level * (1.72 + 0.055 * detail) + vec2(0.23, 0.17);
  }

  float lattice = orbitTexture(q * 0.74 + vec2(0.18 * sin(t * 0.04), 0.0), detail);
  float field = clamp(frames + symbols * 0.9 + lattice * 0.36, 0.0, 1.0);
  vec3 paper = vec3(0.028, 0.012, 0.045);
  vec3 gold = spectralPalette(q.y * 0.16 + q.x * 0.09 + 0.02 * t, scheme + 23.0);
  vec3 color = mix(paper, gold, field);
  color += symbols * vec3(0.42, 0.24, 0.08);
  return color;
}

vec3 auroraTempestColor(vec2 p, float t, float symmetry, float detail, float warp, float scheme) {
  vec2 q = p;
  float symmetryFrequency = floor(clamp(symmetry, 3.0, 12.0));
  float domain = fbm(vec2(q.x * 1.3, q.y * 0.7) + vec2(t * 0.012, -t * 0.004));
  q.x += (domain - 0.5) * (0.25 + 0.18 * warp);

  float curtain = 0.0;
  float curtainPhase = 0.0;
  for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float ridge = 0.18 + fi * 0.12 + 0.12 * sin(q.x * (1.7 + symmetryFrequency * 0.10 + fi * 0.35) + t * (0.035 + fi * 0.006));
    ridge += (fbm(vec2(q.x * 2.4 + fi * 7.0, t * 0.015)) - 0.5) * 0.18 * warp;
    float band = exp(-abs(q.y - ridge) * (12.0 + fi * 2.5));
    curtain += band / (1.0 + fi * 0.35);
    curtainPhase += band * (0.17 * fi + q.x * 0.08);
  }
  curtain = clamp(curtain, 0.0, 1.0);

  float seaHeight = -0.24;
  seaHeight += 0.055 * sin(q.x * (5.0 + symmetryFrequency * 0.60) + t * 0.10);
  seaHeight += 0.032 * sin(q.x * (10.0 + symmetryFrequency) - t * 0.16);
  seaHeight += (fbm(vec2(q.x * 3.2 - t * 0.02, 1.7)) - 0.5) * 0.10;
  float belowSea = 1.0 - smoothstep(seaHeight - 0.02, seaHeight + 0.02, q.y);
  float waveLines = 0.5 + 0.5 * cos((q.y - seaHeight) * (55.0 + detail * 4.0) + q.x * 8.0 - t * 0.22);
  waveLines = pow(waveLines, 9.0) * belowSea;

  float lightningPath = abs(q.x + 0.075 * sin(q.y * 17.0 + fbm(q * 5.0) * 5.0) - 0.35 * sin(t * 0.025));
  float lightning = exp(-lightningPath * 90.0) * smoothstep(-0.05, 0.7, q.y);
  lightning *= smoothstep(0.88, 0.98, sin(t * 0.19) * 0.5 + 0.5);

  vec3 sky = mix(vec3(0.005, 0.012, 0.035), vec3(0.035, 0.018, 0.075), smoothstep(-0.2, 0.8, q.y));
  vec3 aurora = spectralPalette(curtainPhase + 0.03 * t, scheme + 31.0);
  vec3 seaTint = spectralPalette(q.x * 0.08, scheme + 41.0);
  float horizonFoam = exp(-abs(q.y - seaHeight) * 42.0);
  vec3 sea = vec3(0.005, 0.02, 0.045) + seaTint * (0.07 + 0.48 * waveLines);
  sea += waveLines * vec3(0.08, 0.22, 0.32);
  sea += horizonFoam * vec3(0.12, 0.25, 0.34);
  vec3 color = mix(sky, aurora, curtain * smoothstep(-0.12, 0.82, q.y));
  color = mix(color, sea, belowSea * 0.9);
  color += lightning * vec3(0.72, 0.88, 1.0);
  color += orbitTexture(q * 0.45, detail) * 0.08 * aurora;
  return color;
}

vec3 motifColor(int motif, vec2 p, float t, float symmetry, float detail, float warp, float scheme) {
  if (motif == 0) return spiderWebColor(p, t, symmetry, detail, warp, scheme);
  if (motif == 1) return arcaneSigilColor(p, t, symmetry, detail, warp, scheme);
  if (motif == 2) return recursiveCardsColor(p, t, symmetry, detail, warp, scheme);
  return auroraTempestColor(p, t, symmetry, detail, warp, scheme);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePx = max(1.0, min(uResolution.x, uResolution.y));
  vec2 p = (fragCoord - 0.5 * uResolution) / scalePx;
  p = p / max(uZoom, 0.0001) * 2.15 + uCenter;

  float detail = clamp(uDetail, 2.0, 9.0);
  float warp = clamp(uWarp, 0.0, 2.0);
  float symmetry = clamp(uSymmetry, 3.0, 12.0);
  float baseTime = uTime * 3.5 * clamp(uMotion, 0.0, 3.0);
  float t = baseTime + uPhase * TAU;
  float scheme = uColorScheme + uPaletteShift * 19.0;
  int motif = int(clamp(floor(uMotif + 0.5), 0.0, 4.0));

  vec3 color;
  if (motif < 4) {
    color = motifColor(motif, p, t, symmetry, detail, warp, scheme);
  } else {
    // A deterministic four-keyframe loop. Smooth Hermite interpolation keeps
    // visual structure continuous while the procedural subject changes.
    float cycle = mod(uPhase * 4.0 + baseTime, 4.0);
    int current = int(floor(cycle));
    int next = current + 1;
    if (next > 3) next = 0;
    float blend = fract(cycle);
    blend = blend * blend * (3.0 - 2.0 * blend);
    vec3 a = motifColor(current, p, baseTime, symmetry, detail, warp, scheme);
    vec3 b = motifColor(next, p, baseTime, symmetry, detail, warp, scheme);
    color = mix(a, b, blend);
  }

  color = clamp(color, 0.0, 1.0);
  float alpha = 1.0;
  if (uTransparentBg > 0.5) {
    float brightness = max(color.r, max(color.g, color.b));
    alpha = smoothstep(0.085, 0.24, brightness);
  }
  fragColor = vec4(color * alpha, alpha);
}
