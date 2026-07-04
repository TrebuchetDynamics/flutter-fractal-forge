#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uBirthMask;     // 10
uniform float uSurvivalMask;  // 11

out vec4 fragColor;

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

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) return mix(vec3(0.04, 0.05, 0.07), vec3(0.9, 0.95, 0.85), t);
  float s = float(scheme);
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, vec3(0.52), vec3(0.48), vec3(1.0, 0.8, 0.6), d), 0.0, 1.0);
}

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float smoothCell(vec2 p, float v) {
  vec2 f = abs(fract(p) - 0.5);
  float cell = 1.0 - smoothstep(0.42, 0.50, max(float(f.x), float(f.y)));
  return v * cell;
}

float maskHas(float mask, float n) {
  float count = floor(n + 0.5);
  if (mask < 9.0) return 1.0 - step(0.5, abs(count - floor(mask + 0.5)));
  float bit = pow(2.0, clamp(count, 0.0, 8.0));
  return step(bit, mod(floor(mask / bit), 2.0) * bit);
}


// Maze-like Life rule (B3/S12345): stable corridors and branching walls.
void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(float(uResolution.x), float(uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(scale, 1.0);
  vec2 p = uv / max(uZoom, 0.000001) + uCenter;
  vec2 g = floor(p * 58.0);
  float steps = clamp(uIterations, 1.0, 500.0);

  float n = 0.0;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      if (x == 0 && y == 0) continue;
      vec2 q = g + vec2(float(x), float(y));
      float v = hash21(floor(q * 0.19) + floor(steps * 0.018));
      n += step(0.50, sin(v * 9.0 + q.x * 0.27) * 0.5 + 0.5);
    }
  }
  float base = hash21(g * 0.73 + floor(steps * 0.01));
  float birth = maskHas(uBirthMask, n);
  float survive = maskHas(uSurvivalMask, n);
  float alive = mix(birth, survive, step(0.44, base));
  float wall = smoothstep(0.30, 0.90, alive + 0.25 * sin((g.x + g.y) * 0.35));

  if (wall < 0.05 && uTransparentBg > 0.5) { fragColor = vec4(0.0); return; }
  vec3 bg = vec3(0.018, 0.015, 0.025);
  vec3 col = getPaletteColor(0.12 * n + 0.01 * length(g) + steps * 0.001, int(uColorScheme));
  fragColor = vec4(linearToSRGB(mix(bg, col, smoothCell(p * 58.0, wall))), 1.0);
}
