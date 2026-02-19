#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbrot Distance Estimation (DE) Rendering
// Uses the Hubbard-Douady potential: DE = 0.5 * log(|z|^2) * |z| / |dz/dc|
// Exterior pixels glow inversely to their distance from the set boundary,
// creating wireframe-like contour bands. Normal-map mode (50-63) blends
// relief shading with boundary glow for a glowing bas-relief effect.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// colorScheme 0-49: standard palette; 50-63: normal-map bas-relief.
vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.4)),0.5+0.5*cos(6.28318*(t+0.7)));
  } else if (scheme == 1) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.5)),0.5+0.5*cos(6.28318*(t+0.3)),0.5+0.5*cos(6.28318*(t+0.0)));
  } else if (scheme == 2) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.33)),0.5+0.5*cos(6.28318*(t+0.67)));
  } else if (scheme == 3) {
    float g = 0.5+0.5*cos(6.28318*t); return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37*s+0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29*s+0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c*t+d)), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c   = uv / max(0.000001, uZoom) + uCenter;
  vec2 z   = vec2(0.0);
  vec2 der = vec2(0.0);  // dz/dc

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    der = 2.0 * vec2(z.x*der.x - z.y*der.y, z.x*der.y + z.y*der.x) + vec2(1.0, 0.0);
    z   = vec2(z.x*z.x - z.y*z.y + c.x, 2.0*z.x*z.y + c.y);

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2   = max(1e-12, dot(z, z));
  float derLen = max(1e-12, length(der));

  // Hubbard-Douady distance estimate (fractal-space distance to set boundary).
  float de = 0.5 * log(mag2) * sqrt(mag2) / derLen;
  // Normalize by pixel size: pixels * zoom → fractal units per pixel.
  float pixelFrac = de * scale * uZoom;
  // Glow: bright at boundary (pixelFrac ≈ 0), fading outward.
  float glow = exp(-pixelFrac * 4.0);

  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);
    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) % 4;
    vec3 col = palette(baseT, basePal) * light;
    // Brighten near boundary using DE glow.
    col = mix(col, vec3(1.0), glow * 0.6);
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  // Standard: smooth escape-time palette + boundary glow.
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);
  col = mix(col, vec3(1.0), glow * 0.7);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
