#include <flutter/runtime_effect.glsl>

precision highp float;

// Superfractal / random-IFS morph (chaos-game blending).
// Instead of one fixed IFS, the chaos game randomly selects among several
// transform families per iteration (Barnsley fern / dragon / carpet styles).
// A seeded hash drives the selection so the same seed reproduces the same
// blended attractor; the mix parameter biases family weights. Each pixel
// accumulates how often the orbit lands nearby (density field).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (chaos-game iterations per pixel)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uMix;           // 10 (family mix bias 0..1)
uniform float uSeed;          // 11

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash11(float n, float seed) {
  return fract(sin(n * 127.1 + seed * 311.7) * 43758.5453);
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

  float mixb = clamp(uMix, 0.0, 1.0);
  float seed = uSeed;
  int steps = int(clamp(uIterations, 8.0, 240.0));

  // Each pixel runs its own short chaos game from its own start point and
  // accumulates proximity to itself over the orbit (self-density).
  vec2 z = p;
  float density = 0.0;
  for (int i = 0; i < 240; i++) {
    if (i >= steps) break;
    float r = hash11(float(i) + seed, seed);
    // Family selection: fern-ish (affine squeeze) vs dragon-ish (rotate/scale).
    if (r < mixb) {
      // Fern-style affine maps (two of the classic four, blended).
      if (r < mixb * 0.5) {
        z = vec2(0.85 * z.x + 0.04 * z.y, -0.04 * z.x + 0.85 * z.y + 0.25);
      } else {
        z = vec2(0.2 * z.x - 0.26 * z.y, 0.23 * z.x + 0.22 * z.y + 0.3);
      }
    } else {
      // Dragon-style rotation maps.
      float ang = 1.1 + 0.3 * seed;
      if (r > 1.0 - 0.5 * (1.0 - mixb)) ang = -1.35;
      vec2 rz = vec2(z.x * cos(ang) - z.y * sin(ang), z.x * sin(ang) + z.y * cos(ang));
      z = rz * 0.72;
    }
    // Accumulate visits near the pixel's own coordinate.
    vec2 d = z - p;
    density += exp(-60.0 * dot(d, d));
  }

  float t = fract(density * 1.6 + 0.1 * length(p) + uTime * 0.00003);
  vec3 color = palette(t, uColorScheme) * (0.2 + 1.2 * clamp(density * 1.5, 0.0, 1.0));
  float alpha = uTransparentBg > 0.5 ? clamp(density * 2.0, 0.25, 1.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
