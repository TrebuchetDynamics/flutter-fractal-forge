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
uniform float uWarp;
uniform float uPackingScale;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 cdiv(vec2 a, vec2 b) { return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / max(dot(b, b), 1e-6); }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.5);
  vec3 b = vec3(0.5);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.06, 0.13, 0.25); b = vec3(0.22, 0.36, 0.50); d = vec3(0.16, 0.34, 0.62); }
  else if (s < 5.0) { a = vec3(0.34, 0.18, 0.07); b = vec3(0.48, 0.30, 0.12); c = vec3(1.0, 0.78, 0.42); d = vec3(0.0, 0.14, 0.28); }
  return a + b * cos(6.28318 * (c * t + d));
}

vec2 conformalWarp(vec2 z, float amount) {
  vec2 z2 = cmul(z, z);
  vec2 mob = cdiv(z + vec2(0.35, 0.18) * amount, vec2(1.0, 0.0) + vec2(0.18, -0.22) * amount * z);
  return mix(z, mob + 0.22 * amount * z2, clamp(amount * 0.5, 0.0, 1.0));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = uResolution.x < uResolution.y ? uResolution.x : uResolution.y;
  scalePix = scalePix < 1.0 ? 1.0 : scalePix;
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 2.5 / max(uZoom, 0.0001) + uCenter;
  float warp = clamp(uWarp, 0.0, 2.0);
  vec2 z = conformalWarp(p, warp);

  float packing = clamp(uPackingScale, 3.0, 14.0);
  vec2 basis = vec2(1.0, 1.7320508);
  vec2 q = vec2(z.x + z.y * 0.5773503, z.y * 1.1547005) * packing;
  vec2 cell = floor(q);
  vec2 f = fract(q) - 0.5;
  float best = 8.0;
  float second = 8.0;
  float id = 0.0;

  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 g = vec2(float(x), float(y));
      vec2 h = cell + g;
      vec2 center = g + vec2(0.5) + 0.08 * vec2(sin(hash(h) * 6.28318 + uTime * 0.00015), cos(hash(h + 3.1) * 6.28318));
      vec2 r = center - fract(q);
      float d = length(r);
      if (d < best) { second = best; best = d; id = hash(h); }
      else if (d < second) { second = d; }
    }
  }

  float radius = 0.28 + 0.16 * hash(cell + floor(uIterations));
  float circle = 1.0 - smoothstep(radius, radius + 0.018, best);
  float ring = 1.0 - smoothstep(0.012, 0.035, abs(best - radius));
  float gap = smoothstep(0.0, 0.12, second - best);
  float diskFade = 1.0 - smoothstep(1.35, 1.85, length(p));
  vec3 color = palette(fract(id + best * 0.7 + warp * 0.13), uColorScheme) * (0.25 + 0.8 * circle) * diskFade;
  color = mix(color, vec3(0.92, 0.86, 0.68), ring * 0.75);
  color += vec3(0.55, 0.75, 1.0) * gap * circle * 0.12;
  float alpha = max(circle * 0.75, ring) * diskFade;
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.006, 0.007, 0.014), color, clamp(alpha, 0.0, 1.0));
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
