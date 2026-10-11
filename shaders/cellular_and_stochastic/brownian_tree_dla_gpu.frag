#include <flutter/runtime_effect.glsl>

precision highp float;

// Bounded, seeded particle-attachment approximation for DLAF-style growth.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg; // 9
uniform float uBranchDensity; // 10
uniform float uJitter; // 11
uniform float uSeed; // 12

out vec4 fragColor;

float hash(float n) {
  return fract(sin((n + uSeed * 13.37) * 127.1 + 311.7) * 43758.5453123);
}

float hash2(vec2 p) {
  p += vec2(uSeed * 0.173, uSeed * 0.319);
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 randomDirection(float n) {
  float angle = 6.2831853 * hash(n + 53.0);
  return vec2(cos(angle), sin(angle));
}

float segmentDistance(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
  return length(pa - ba * h);
}

vec2 particlePosition(int particleId) {
  if (particleId == 0) return vec2(0.0);
  int node = particleId + 1;
  int cursor = node;
  int depth = 0;
  for (int i = 0; i < 6; i++) {
    if (cursor <= 1) break;
    cursor = (cursor - 2) / 3 + 1;
    depth++;
  }

  vec2 position = vec2(0.0);
  for (int level = 0; level < 6; level++) {
    if (level >= depth) break;
    int childNode = node;
    for (int climb = 0; climb < 6; climb++) {
      if (climb >= depth - level - 1) break;
      childNode = (childNode - 2) / 3 + 1;
    }
    vec2 randomStep = randomDirection(float(childNode) * 13.0 + float(level));
    vec2 radial = length(position) > 0.0001 ? normalize(position) : randomStep;
    vec2 drift = normalize(randomStep * 0.82 + radial * 0.42);
    float spacing = (0.12 + 0.10 * hash(float(childNode) + 29.0)) *
        (1.0 - 0.06 * float(level)) *
        (1.0 + 0.35 * uJitter * (hash(float(childNode) + 31.0) - 0.5));
    position += drift * spacing;
  }
  return position;
}

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 hotA = vec3(0.04, 0.08, 0.12);
  vec3 hotB = vec3(0.20, 0.65, 1.00);
  vec3 hotC = vec3(1.00, 0.92, 0.55);
  if (s > 2.5 && s < 5.5) {
    hotA = vec3(0.08, 0.03, 0.02);
    hotB = vec3(0.80, 0.22, 0.08);
    hotC = vec3(1.00, 0.78, 0.28);
  } else if (s >= 5.5) {
    hotA = vec3(0.02, 0.06, 0.04);
    hotB = vec3(0.16, 0.62, 0.22);
    hotC = vec3(0.82, 0.94, 0.62);
  }
  return mix(mix(hotA, hotB, smoothstep(0.0, 0.7, t)), hotC, smoothstep(0.72, 1.0, t));
}

void main() {
  // Seeded three-way branching keeps the shader bounded on mobile GPUs.
  float density = clamp(uBranchDensity, 0.4, 2.5);
  int pointCount = int(clamp(uIterations * density * 0.65, 16.0, 64.0));

  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 2.0 / max(uZoom, 0.0001) + uCenter;
  float distanceValue = length(p - particlePosition(0)) - 0.028;
  float age = 0.0;

  for (int i = 1; i < 64; i++) {
    if (i >= pointCount) break;
    float fi = float(i);
    vec2 point = particlePosition(i);
    vec2 parent = particlePosition((i - 1) / 3);
    float radius = 0.016 * (1.0 - 0.18 * fi / float(pointCount));
    float local = min(
      length(p - point) - radius,
      segmentDistance(p, parent, point) - 0.013
    );
    if (local < distanceValue) {
      distanceValue = local;
      age = fi / float(pointCount);
    }
  }

  float branch = 1.0 - smoothstep(0.002, 0.012 / max(uZoom, 0.3), distanceValue);
  float halo = exp(-max(distanceValue, 0.0) * 42.0) * 0.38;
  float grain = hash2(floor(p * 95.0));
  branch *= 0.82 + 0.18 * grain;
  vec3 color = palette(fract(age + grain * 0.1), uColorScheme) *
      max(branch, halo);
  float alpha = max(branch, halo * 0.75);
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.006, 0.007, 0.012), color, clamp(alpha, 0.0, 1.0));
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
