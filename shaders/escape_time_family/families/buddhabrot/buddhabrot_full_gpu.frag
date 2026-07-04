#include <flutter/runtime_effect.glsl>

precision highp float;

// Buddhabrot (Full) — progressive single-pass approximation.
// For each pixel, launch multiple test orbits from pseudo-random starting points
// in the Mandelbrot c-plane. Track which orbits ESCAPE and count how many orbit
// points pass through this pixel's location, approximating histogram density.
// Extra params:
//   uSamples (float 10): number of test orbits per pixel (default 8, range 4..32)
//   uMinIter (float 11): minimum iterations for orbit to count (default 20)
// Supports normal-map shading (colorScheme 50-63).

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uSamples;       // 10
uniform float uMinIter;       // 11

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear -> display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  } else if (scheme == 1) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  } else if (scheme == 2) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c_v = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c_v * t + d)), 0.0, 1.0);
}

// ---------- pseudo-random hash ----------
float hash21(vec2 p) {
  p = fract(p * vec2(443.8975, 397.2973));
  p += dot(p, p + 19.19);
  return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
  return vec2(hash21(p), hash21(p + vec2(37.17, 53.91)));
}

vec2 buddhabrotSeed(float index) {
  float a = index + 1.0;
  float angle = a * 2.39996322973;
  float radius = mix(0.22, 1.75, fract(a * 0.61803398875));
  vec2 c = vec2(-0.55, 0.0) + radius * vec2(cos(angle), 0.75 * sin(angle));
  c += (vec2(fract(a * 0.754877666), fract(a * 0.569840296)) - 0.5) * 0.18;
  return clamp(c, vec2(-2.0, -1.5), vec2(1.0, 1.5));
}

const int MAX_ITERS = 300;
const int MAX_SAMPLES = 32;

// Run a single Mandelbrot orbit from starting c, return escape iteration
// (-1 if bounded). Store orbit points in a fixed-size array approximation:
// we replay the orbit and count hits near our target pixel.
float buddhabrotDensity(vec2 pixel, vec2 c, int maxIter, int minIter, float bailoutSq, float pixelRadius) {
  // First pass: determine if orbit escapes
  vec2 z = vec2(0.0);
  int escapeIter = -1;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= maxIter) break;
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > bailoutSq) {
      escapeIter = i;
      break;
    }
  }

  // Only count escaping orbits with sufficient iterations
  if (escapeIter < 0 || escapeIter < minIter) return 0.0;

  // Second pass: replay orbit and count points near this pixel
  z = vec2(0.0);
  float hits = 0.0;
  float radiusSq = pixelRadius * pixelRadius;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= escapeIter) break;
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

    // Soft hit: Gaussian proximity weight
    vec2 diff = z - pixel;
    float d2 = dot(diff, diff);
    hits += exp(-d2 / (2.0 * radiusSq));
  }

  return hits;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 pixel = uv / max(0.000001, uZoom) + uCenter;

  int maxIter = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int numSamples = int(clamp(max(uSamples, 18.0), 4.0, float(MAX_SAMPLES)));
  int minIter = int(clamp(max(uMinIter, 10.0), 1.0, float(maxIter)));
  float bailoutSq = uBailout * uBailout;
  int schemeInt = int(uColorScheme);

  // Pixel radius in world space (for hit detection). A few screen pixels are
  // intentional: this single-pass preview has no persistent histogram buffer.
  float pixelRadius = 4.0 / (max(0.000001, uZoom) * scale);

  // Use the same deterministic escaping orbits for every fragment. Per-pixel
  // random seeds make uncorrelated speckle, not a Buddhabrot histogram.
  float totalDensity = 0.0;

  for (int s = 0; s < MAX_SAMPLES; s++) {
    if (s >= numSamples) break;
    vec2 c = buddhabrotSeed(float(s));
    totalDensity += buddhabrotDensity(pixel, c, maxIter, minIter, bailoutSq, pixelRadius);
  }

  // Log-scale for dynamic range
  float logDens = log(1.0 + totalDensity * 0.5) / log(2.0 + float(numSamples));

  // Normal-map shading (colorScheme 50-63)
  if (schemeInt >= 50) {
    float eps = 0.003 / max(0.000001, uZoom);
    // Compute density at offset pixels for gradient
    float densR = 0.0;
    float densU = 0.0;
    vec2 pixR = pixel + vec2(eps, 0.0);
    vec2 pixU = pixel + vec2(0.0, eps);

    // Simplified: use fewer samples for normal-map neighbours
    for (int s = 0; s < MAX_SAMPLES; s++) {
      if (s >= numSamples / 2) break;
      vec2 c = buddhabrotSeed(float(s));
      densR += buddhabrotDensity(pixR, c, maxIter, minIter, bailoutSq, pixelRadius);
      densU += buddhabrotDensity(pixU, c, maxIter, minIter, bailoutSq, pixelRadius);
    }

    float logR = log(1.0 + densR * 0.5) / log(2.0 + float(numSamples));
    float logU = log(1.0 + densU * 0.5) / log(2.0 + float(numSamples));

    vec2 grad = vec2(logR - logDens, logU - logDens) / eps;
    float gLen = length(grad);
    vec2 nv = (gLen > 1e-6) ? grad / gLen : vec2(0.0);

    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(logDens * 2.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  if (logDens < 0.005 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Color by accumulated density
  float t = fract(logDens * 2.0 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);

  // Brightness modulation: no density should be black, as in a Buddhabrot
  // histogram, not a colored Mandelbrot-style exterior fill.
  float brightness = smoothstep(0.0, 0.35, logDens);
  col *= 1.4 * brightness;
  col = clamp(col, 0.0, 1.0);

  float alpha = (uTransparentBg > 0.5) ? smoothstep(0.0, 0.02, logDens) : 1.0;
  fragColor = vec4(linearToSRGB(col), alpha);
}
