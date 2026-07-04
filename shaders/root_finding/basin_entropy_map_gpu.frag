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
uniform float uDegree;
uniform float uSampleRadius;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 cdiv(vec2 a, vec2 b) { return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / max(dot(b, b), 1e-8); }

vec2 cpowN(vec2 z, int n) {
  vec2 r = vec2(1.0, 0.0);
  for (int i = 0; i < 5; i++) {
    if (i >= n) break;
    r = cmul(r, z);
  }
  return r;
}

float rootClass(vec2 z, int degree) {
  int maxIter = int(clamp(uIterations, 8.0, 120.0));
  for (int i = 0; i < 120; i++) {
    if (i >= maxIter) break;
    vec2 zn = cpowN(z, degree) - vec2(1.0, 0.0);
    vec2 dz = float(degree) * cpowN(z, degree - 1);
    z -= cdiv(zn, dz);
    if (length(zn) < 0.0001) break;
  }
  float a = atan(z.y, z.x);
  float cls = floor(mod((a + 3.14159265) / 6.2831853 * float(degree) + 0.5, float(degree)));
  return cls;
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.5);
  vec3 b = vec3(0.5);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.05, 0.10, 0.22); b = vec3(0.30, 0.35, 0.55); d = vec3(0.55, 0.22, 0.04); }
  else if (s < 5.0) { a = vec3(0.30, 0.12, 0.04); b = vec3(0.50, 0.25, 0.10); c = vec3(1.0, 0.75, 0.35); d = vec3(0.0, 0.12, 0.28); }
  return a + b * cos(6.28318 * (c * t + d));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 z = uv * 3.0 / max(uZoom, 0.0001) + uCenter;
  int degree = int(clamp(floor(uDegree + 0.5), 3.0, 5.0));
  float sr = clamp(uSampleRadius, 0.002, 0.06) / max(uZoom, 0.25);

  float c0 = rootClass(z, degree);
  float diff = 0.0;
  float seen = 1.0;
  float accum = c0;
  for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
      if (i == 0 && j == 0) continue;
      float c = rootClass(z + vec2(float(i), float(j)) * sr, degree);
      diff += step(0.5, abs(c - c0));
      accum += c;
      seen += 1.0;
    }
  }
  float entropy = diff / 8.0;
  float basin = accum / max(seen * float(degree - 1), 1.0);
  vec3 basinColor = palette(fract(basin + c0 / float(degree)), uColorScheme);
  vec3 heat = mix(vec3(0.02, 0.04, 0.10), vec3(1.0, 0.32, 0.05), smoothstep(0.05, 0.85, entropy));
  vec3 color = mix(basinColor * 0.42, heat, smoothstep(0.02, 0.7, entropy));
  color += vec3(1.0, 0.9, 0.55) * pow(entropy, 3.0) * 0.35;
  float alpha = uTransparentBg > 0.5 ? smoothstep(0.02, 0.18, entropy) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
