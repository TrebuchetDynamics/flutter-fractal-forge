#include <flutter/runtime_effect.glsl>

precision highp float;

// Domain-Warped Nebula — clean-room, single-pass procedural noise field.
//
// Ridged fractal Brownian motion warped by itself twice: the first fBm displaces
// the second, the second displaces the third. Each warp turn converts smooth
// gradient noise into filaments, then into folded sheet structure, which is what
// separates this from a plain fBm or plasma carpet. Fully procedural, no
// textures, no multipass state.

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;     // detail budget: each fBm layer uses iterations/6 octaves
uniform float uBailout;        // unused, kept for the shared ABI
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uWarpStrength;
uniform float uRidgeMix;

out vec4 fragColor;

const int MAX_OCTAVES = 8;

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

// Cohesive ink -> blue -> violet -> magenta -> gold -> warm white ramp.
vec3 nebulaRamp(float t) {
  t = clamp(t, 0.0, 1.0);
  vec3 c = mix(vec3(0.010, 0.014, 0.030), vec3(0.055, 0.115, 0.300), smoothstep(0.00, 0.18, t));
  c = mix(c, vec3(0.230, 0.170, 0.520), smoothstep(0.18, 0.38, t));
  c = mix(c, vec3(0.750, 0.270, 0.480), smoothstep(0.38, 0.58, t));
  c = mix(c, vec3(0.980, 0.640, 0.260), smoothstep(0.58, 0.78, t));
  c = mix(c, vec3(1.000, 0.960, 0.840), smoothstep(0.78, 1.00, t));
  return c;
}

vec3 schemeColor(float t, int scheme) {
  if (scheme == 0) return nebulaRamp(t);
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.45), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  return iqPalette(t, vec3(0.45), vec3(0.45), vec3(0.9, 1.0, 1.1), vec3(0.10, 0.34, 0.64));
}

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash21(i);
  float b = hash21(i + vec2(1.0, 0.0));
  float c = hash21(i + vec2(0.0, 1.0));
  float d = hash21(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

mat2 gRot(float a) {
  float c = cos(a), s = sin(a);
  return mat2(c, -s, s, c);
}

// RidgeMix blends smooth value noise into a ridged transformation: at 1.0 the
// zero-crossings become continuous bright crests instead of soft dunes.
float fbm(vec2 p, int octaves, float ridgeMix, float t) {
  float total = 0.0;
  float amplitude = 1.0;
  float norm = 0.0;
  mat2 turn = gRot(0.72);
  for (int o = 0; o < MAX_OCTAVES; o++) {
    if (o >= octaves) break;
    float n = valueNoise(p + t * 0.35 * float(o + 1));
    float ridged = 1.0 - abs(2.0 * n - 1.0);
    total += amplitude * mix(n, ridged, ridgeMix);
    norm += amplitude;
    amplitude *= 0.55;
    p = turn * p * 2.03;
  }
  return total / max(norm, 1e-5);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv * 3.4 / max(0.000001, uZoom) + uCenter;

  // The shared escape-time ABI floors `iterations` at 20, so the control is a
  // detail budget rather than a raw count: 30 -> 5 octaves per layer.
  int octaves = int(clamp(floor(uIterations / 6.0), 1.0, float(MAX_OCTAVES)));
  float ridge = clamp(uRidgeMix, 0.0, 1.0);
  float warp = clamp(uWarpStrength, 0.0, 6.0);
  float t = uTime * 0.00002;

  float q = fbm(p, octaves, 0.0, t);
  float r = fbm(p + warp * q + vec2(3.1, -2.4), octaves, ridge, t * 1.7);
  float f = fbm(p + warp * r * 1.3 + vec2(-1.2, 5.0), octaves, ridge, t * 2.3);

  float v = clamp(0.55 * f + 0.45 * r, 0.0, 1.0);
  float density = pow(clamp((v - 0.42) * 3.2, 0.0, 1.0), 1.7);
  float shade = clamp(0.06 + 0.80 * pow(max(density, 0.0), 0.9), 0.0, 1.0);

  vec3 color = schemeColor(shade, int(uColorScheme));
  color *= 0.12 + 0.95 * density;

  if (density < 0.004 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
