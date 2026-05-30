#include <flutter/runtime_effect.glsl>

precision highp float;

// Julia Set Distance Estimation (DE) Glow
// Renders the Julia set boundary as glowing contour lines using the
// Hubbard-Douady distance formula: DE = 0.5 * log(|z|^2) * |z| / |dz/dz0|
// The hardcoded seed c = (-0.7, 0.27) produces the classic "dragon" shape.
// colorScheme 50-63: normal-map (bas-relief) mode — 14 light angles × 4 palettes.
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.33,0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.10,0.20));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.0,0.15,0.20));
  if (scheme == 3) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0));
  float s = float(scheme);
  vec3 a = vec3(0.5 + 0.2*sin(s*1.1), 0.5 + 0.2*sin(s*1.3), 0.5 + 0.2*sin(s*1.7));
  vec3 b = vec3(0.5 + 0.3*cos(s*0.7), 0.5 + 0.3*cos(s*1.1), 0.5 + 0.3*cos(s*0.3));
  vec3 c = vec3(1.0 + sin(s*0.5), 1.0 + sin(s*0.9), 1.0 + sin(s*1.3));
  vec3 d = vec3(fract(s*0.13), fract(s*0.17), fract(s*0.23));
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 z    = uv / max(uZoom, 1e-6) + uCenter;
  vec2 seed = vec2(-0.7, 0.27);  // classic dragon Julia

  // dz/dz0 for Julia DE (initial der = 1, no +1 since c is constant)
  vec2 der = vec2(1.0, 0.0);

  float bailoutSq = max(4.0, uBailout * uBailout);
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;

    der = 2.0 * vec2(z.x*der.x - z.y*der.y, z.x*der.y + z.y*der.x);
    z   = vec2(z.x*z.x - z.y*z.y + seed.x, 2.0*z.x*z.y + seed.y);

    if (dot(z, z) > bailoutSq) { it = j; break; }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2   = max(1e-12, dot(z, z));
  float derLen = max(1e-12, length(der));

  // Hubbard-Douady DE for Julia set
  float de = 0.5 * log(mag2) * sqrt(mag2) / derLen;
  float pixelFrac = de * scale * uZoom;
  float glow = exp(-pixelFrac * 4.0);

  float smoothVal = float(it) - log2(log2(mag2));

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
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    vec3 col = getPaletteColor(baseT, basePal) * light;
    col = mix(col, vec3(1.0), glow * 0.6);
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  vec3 col = getPaletteColor(t, schemeInt);
  col = mix(col, vec3(1.0), glow * 0.7);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
