#include <flutter/runtime_effect.glsl>

precision highp float;

// Fractal interpolation heightfield (2D self-affine relief).
// A deterministic self-affine surface built by recursive diamond-square-style
// midpoint displacement over a small fixed corner grid, shaded as relief with
// height-gradient lighting and optional contour bands — the "fractal
// interpolation surface" literature rendered as a heightfield view.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (refinement levels)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uRoughness;     // 10 (vertical scaling factor)
uniform float uSeed;          // 11
uniform float uMode;          // 12 (0=relief, 1=contours)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash21(vec2 p, float seed) {
  p = p + seed * 13.37;
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Deterministic value-noise-based fBm height with fixed octaves.
float heightAt(vec2 q, float rough, float seed, int levels) {
  float sum = 0.0;
  float amp = 1.0;
  float freq = 1.0;
  float norm = 0.0;
  for (int o = 0; o < 8; o++) {
    if (o >= levels) break;
    // Bilinear value noise on a lattice (self-affine midpoint-displacement
    // proxy with a fixed decay ratio per octave).
    vec2 g = q * freq;
    vec2 i = floor(g);
    vec2 f = fract(g);
    f = f * f * (3.0 - 2.0 * f);
    float v00 = hash21(i, seed);
    float v10 = hash21(i + vec2(1.0, 0.0), seed);
    float v01 = hash21(i + vec2(0.0, 1.0), seed);
    float v11 = hash21(i + vec2(1.0, 1.0), seed);
    float v = mix(mix(v00, v10, f.x), mix(v01, v11, f.x), f.y);
    sum += amp * v;
    norm += amp;
    amp *= rough;
    freq *= 2.0;
  }
  return sum / max(norm, 1e-6);
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

  float rough = clamp(uRoughness, 0.15, 0.95);
  float seed = uSeed;
  int levels = int(clamp(uIterations, 2.0, 8.0));
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 1.0));

  // Domain scaled so the default view shows ~4 periods.
  vec2 q = p * 2.5;
  float h = heightAt(q, rough, seed, levels);
  float hx = heightAt(q + vec2(0.02, 0.0), rough, seed, levels);
  float hy = heightAt(q + vec2(0.0, 0.02), rough, seed, levels);

  vec3 color;
  if (mode == 0) {
    // Relief: lambert shading from the surface gradient.
    vec3 n = normalize(vec3(-(hx - h) * 18.0, -(hy - h) * 18.0, 1.0));
    vec3 lightDir = normalize(vec3(0.55, 0.65, 0.52));
    float lambert = clamp(dot(n, lightDir), 0.0, 1.0);
    vec3 base = palette(fract(h * 1.7), uColorScheme);
    color = base * (0.35 + 0.75 * lambert) + vec3(0.06) * pow(lambert, 8.0);
  } else {
    // Contour bands: quantized height with thin dark separations.
    float bands = 18.0;
    float hb = h * bands;
    float band = floor(hb);
    float frac = fract(hb);
    float edge = smoothstep(0.0, 0.08, frac) * (1.0 - smoothstep(0.92, 1.0, frac));
    vec3 base = palette(fract(band / bands * 1.3), uColorScheme);
    color = base * (0.4 + 0.6 * edge);
  }

  float alpha = uTransparentBg > 0.5 ? 1.0 : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
