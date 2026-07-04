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
uniform float uRadius;
uniform float uSymmetry;

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
  if (s < 1.0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s < 2.0) return iqPalette(t, vec3(0.35, 0.22, 0.10), vec3(0.45, 0.25, 0.12), vec3(1.0, 0.7, 0.4), vec3(0.0, 0.12, 0.24));
  if (s < 3.0) return iqPalette(t, vec3(0.08, 0.12, 0.20), vec3(0.25, 0.35, 0.55), vec3(0.8, 1.0, 1.2), vec3(0.10, 0.30, 0.55));
  return iqPalette(t, vec3(0.48), vec3(0.50), vec3(1.0, 0.8, 0.6), vec3(fract(s * 0.19), 0.35, 0.7));
}

bool invertCircle(inout vec2 p, vec2 c, float r, inout float scale) {
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
  vec2 p0 = uv * 2.5 / max(uZoom, 0.0001) + uCenter;

  vec2 p = p0;
  float invScale = 1.0;
  float hits = 0.0;
  float code = 0.0;
  int maxIter = int(clamp(uIterations, 1.0, 80.0));
  int symmetry = int(clamp(uSymmetry, 3.0, 8.0));
  float radius = clamp(uRadius, 0.25, 1.4);
  float orbitMin = 10.0;

  for (int i = 0; i < 80; i++) {
    if (i >= maxIter) break;
    bool any = false;
    for (int j = 0; j < 8; j++) {
      if (j >= symmetry) break;
      float a = 6.2831853 * float(j) / float(symmetry) + 0.08 * sin(uTime * 0.0002);
      vec2 c = vec2(cos(a), sin(a)) * 0.82;
      if (invertCircle(p, c, radius, invScale)) {
        any = true;
        hits += 1.0;
        code += float(j + 1) / float(symmetry + 1);
      }
      orbitMin = min(orbitMin, abs(length(p0 - c) - radius));
    }
    if (invertCircle(p, vec2(0.0), radius * 0.58, invScale)) {
      any = true;
      hits += 1.0;
      code += 0.37;
    }
    orbitMin = min(orbitMin, abs(length(p0) - radius * 0.58));
    if (!any) break;
  }

  float lace = exp(-orbitMin * 95.0 / max(uZoom, 0.2));
  float limit = smoothstep(0.0, 0.7, hits / max(uIterations, 1.0));
  float band = 0.5 + 0.5 * cos(log(max(invScale, 1.0)) * 0.55 + code * 4.0);
  float t = fract(code * 0.13 + hits * 0.021 + band * 0.2 + uTime * 0.00003);
  vec3 color = palette(t, uColorScheme) * (0.35 + 0.75 * max(lace, limit));
  color += vec3(0.8, 0.9, 1.0) * lace * 0.35;

  float alpha = max(lace, limit);
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.01, 0.01, 0.018), color, alpha);
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
