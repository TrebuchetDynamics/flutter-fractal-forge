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
uniform float uBranchDensity;
uniform float uJitter;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(float n) {
  return fract(sin(n * 127.1 + 311.7) * 43758.5453123);
}

float hash2(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float segDist(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
  return length(pa - ba * h);
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
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 3.2 / max(uZoom, 0.0001) + uCenter;

  float density = clamp(uBranchDensity, 0.4, 2.5);
  float jitter = clamp(uJitter, 0.0, 2.0);
  float maxBranches = clamp(uIterations * density * 0.35, 18.0, 64.0);
  float d = length(p) - 0.055;
  float age = 0.0;
  float glow = exp(-length(p) * 7.0);

  for (int i = 0; i < 64; i++) {
    float fi = float(i);
    if (fi >= maxBranches) break;

    float ring = floor(fi / 8.0);
    float slot = mod(fi, 8.0);
    float seed = fi + 17.0 * ring;
    float baseA = 6.2831853 * (slot / 8.0 + 0.13 * hash(seed));
    float a = baseA + jitter * 0.55 * (hash(seed + 2.0) - 0.5) + 0.04 * sin(uTime * 0.0002 + seed);
    float startR = 0.07 + ring * 0.105 + 0.03 * hash(seed + 4.0);
    float len = (0.22 + 0.16 * hash(seed + 9.0)) * (1.0 - 0.045 * ring);
    len = max(len, 0.055);

    vec2 dir = vec2(cos(a), sin(a));
    vec2 bend = vec2(cos(a + 1.25 * (hash(seed + 6.0) - 0.5)),
                     sin(a + 1.25 * (hash(seed + 6.0) - 0.5)));
    vec2 a0 = dir * startR;
    vec2 a1 = dir * (startR + len * 0.58) + bend * len * 0.18 * jitter;
    vec2 a2 = dir * (startR + len) + bend * len * 0.35 * jitter;

    float local = min(segDist(p, a0, a1), segDist(p, a1, a2));
    float twigA = a + (hash(seed + 11.0) - 0.5) * 1.8;
    vec2 twig = a2 + vec2(cos(twigA), sin(twigA)) * len * 0.38;
    local = min(local, segDist(p, a1, twig));

    if (local < d) {
      d = local;
      age = fi / max(maxBranches, 1.0);
    }
    glow += exp(-local * 42.0) * 0.018;
  }

  float width = 0.018 / max(uZoom, 0.3);
  float branch = 1.0 - smoothstep(width, width * 2.4, d);
  float halo = exp(-d * 38.0) * 0.45;
  float grain = hash2(floor(p * 95.0));
  branch *= 0.8 + 0.25 * grain;

  vec3 color = palette(fract(age + glow * 0.2), uColorScheme) * max(branch, halo);
  color += vec3(0.7, 0.9, 1.0) * glow * 0.18;

  float alpha = max(branch, halo * 0.75);
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.006, 0.007, 0.012), color, clamp(alpha, 0.0, 1.0));
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
