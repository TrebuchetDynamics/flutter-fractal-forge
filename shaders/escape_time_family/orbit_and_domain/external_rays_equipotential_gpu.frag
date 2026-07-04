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
uniform float uRayDensity;
uniform float uPotentialBands;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.5), b = vec3(0.5), c = vec3(1.0), d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.04,0.10,0.22); b = vec3(0.25,0.35,0.55); d = vec3(0.56,0.22,0.04); }
  else if (s < 5.0) { a = vec3(0.35,0.18,0.06); b = vec3(0.48,0.30,0.12); c = vec3(1.0,0.8,0.45); d = vec3(0.0,0.13,0.28); }
  return a + b * cos(6.28318 * (c * t + d));
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 c = uv * 3.0 / max(uZoom, 0.0001) + uCenter;
  vec2 z = vec2(0.0);
  int maxIter = int(clamp(uIterations, 20.0, 260.0));
  float escaped = 0.0;
  float it = 0.0;
  float bailout = max(uBailout, 4.0);

  for (int i = 0; i < 260; i++) {
    if (i >= maxIter) break;
    z = cmul(z, z) + c;
    if (dot(z, z) > bailout * bailout) { escaped = 1.0; it = float(i); break; }
    it = float(i);
  }

  float r = max(length(z), 1.0001);
  float potential = log(log(r)) / log(2.0) - it;
  float angle = atan(z.y, z.x) / 6.2831853 + 0.5;
  float rays = 1.0 - smoothstep(0.010, 0.035, abs(fract(angle * clamp(uRayDensity, 4.0, 48.0)) - 0.5));
  float equip = 1.0 - smoothstep(0.015, 0.055, abs(fract(potential * clamp(uPotentialBands, 2.0, 32.0)) - 0.5));
  float boundary = 1.0 - smoothstep(0.0, 0.08, escaped);

  vec3 base = escaped > 0.5 ? palette(fract(it / max(uIterations, 1.0) + potential * 0.03), uColorScheme) : vec3(0.01,0.012,0.018);
  vec3 guide = vec3(0.95, 0.86, 0.55) * equip + vec3(0.45, 0.75, 1.0) * rays;
  vec3 color = mix(base * 0.55, guide, clamp(max(equip, rays) * escaped, 0.0, 1.0));
  color += vec3(0.9, 0.45, 0.2) * boundary * 0.25;
  float alpha = uTransparentBg > 0.5 ? max(max(equip, rays) * escaped, boundary * 0.3) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
