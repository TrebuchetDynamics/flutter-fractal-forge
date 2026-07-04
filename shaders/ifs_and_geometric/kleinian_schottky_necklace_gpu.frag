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
uniform float uCircleRadius;
uniform float uTwist;

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

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  if (s < 1.0) return iqPalette(t, vec3(0.48), vec3(0.50), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s < 2.0) return iqPalette(t, vec3(0.36, 0.22, 0.09), vec3(0.42, 0.28, 0.12), vec3(1.0, 0.7, 0.35), vec3(0.0, 0.14, 0.29));
  if (s < 3.0) return iqPalette(t, vec3(0.08, 0.14, 0.26), vec3(0.22, 0.30, 0.48), vec3(0.8, 1.0, 1.2), vec3(0.18, 0.36, 0.64));
  return iqPalette(t, vec3(0.50), vec3(0.48), vec3(1.0, 0.75, 0.55), vec3(fract(s * 0.197), 0.27, 0.61));
}

vec2 rot(vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

bool invert(inout vec2 p, inout float scale, vec2 c, float r) {
  vec2 d = p - c;
  float l2 = dot(d, d);
  float r2 = r * r;
  if (l2 < r2) {
    float k = r2 / max(l2, 1e-6);
    p = c + d * k;
    scale *= k;
    return true;
  }
  return false;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p0 = uv * 3.0 / max(uZoom, 0.0001) + uCenter;
  vec2 p = p0;

  float radius = clamp(uCircleRadius, 0.28, 1.1);
  float twist = clamp(uTwist, -1.5, 1.5) + 0.04 * sin(uTime * 0.00017);
  int maxIter = int(clamp(uIterations, 1.0, 96.0));
  float scaleAccum = 1.0;
  float hits = 0.0;
  float code = 0.0;
  float orbit = 10.0;

  for (int i = 0; i < 96; i++) {
    if (i >= maxIter) break;
    bool changed = false;
    float fi = float(i);
    float spacing = 1.15 + 0.35 * radius;

    // Four Schottky-style generator circles, then loxodromic twist/translation.
    vec2 c1 = vec2(-spacing, 0.0);
    vec2 c2 = vec2( spacing, 0.0);
    vec2 c3 = rot(vec2(0.0, spacing * 0.82), twist);
    vec2 c4 = rot(vec2(0.0,-spacing * 0.82), twist);

    if (invert(p, scaleAccum, c1, radius)) { changed = true; code += 0.17; }
    if (invert(p, scaleAccum, c2, radius)) { changed = true; code += 0.31; }
    if (invert(p, scaleAccum, c3, radius * 0.86)) { changed = true; code += 0.47; }
    if (invert(p, scaleAccum, c4, radius * 0.86)) { changed = true; code += 0.63; }

    orbit = min(orbit, abs(length(p0 - c1) - radius));
    orbit = min(orbit, abs(length(p0 - c2) - radius));
    orbit = min(orbit, abs(length(p0 - c3) - radius * 0.86));
    orbit = min(orbit, abs(length(p0 - c4) - radius * 0.86));

    if (!changed) break;
    hits += 1.0;
    p = rot(p, twist * 0.18) + vec2(0.055 * sin(fi * 1.7), 0.035 * cos(fi * 1.3));
  }

  float necklace = exp(-orbit * 120.0 / max(uZoom, 0.25));
  float limit = smoothstep(0.02, 0.7, hits / max(uIterations, 1.0));
  float bands = 0.5 + 0.5 * cos(log(max(scaleAccum, 1.0)) * 0.42 + code * 5.2);
  float t = fract(code * 0.07 + hits * 0.027 + bands * 0.23 + uTime * 0.00002);
  vec3 color = palette(t, uColorScheme) * (0.25 + 0.85 * max(limit, necklace));
  color += vec3(0.9, 0.82, 1.0) * necklace * 0.42;

  float alpha = max(limit, necklace);
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.008, 0.008, 0.018), color, clamp(alpha, 0.0, 1.0));
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
