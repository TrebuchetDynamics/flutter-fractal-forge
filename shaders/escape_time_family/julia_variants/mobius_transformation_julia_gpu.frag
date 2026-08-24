#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbrot/Julia set of a Möbius-transformation-wrapped quadratic map.
// The iteration is M(z) -> M(z)^2 + c where
//   M(z) = (p z + q) / (r z + s),  det = p*s - q*r kept away from 0.
// Wrapping a quadratic escape-time map in a fractional-linear transform warps
// the basins and preserves circles, bridging escape-time and inversive
// geometry. Coefficients are exposed as curated params (Möbius Julia/Dual
// families); the default preset uses the identity-ish twist.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uParamP;        // 10 (p, real)
uniform float uParamQ;        // 11 (q, real)
uniform float uParamR;        // 12 (r, real)
uniform float uParamS;        // 13 (s, real)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 cdiv(vec2 a, vec2 b) { return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / max(dot(b, b), 1e-7); }

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
  vec2 c = uv * 3.0 / max(uZoom, 0.0001) + uCenter;

  float p = uParamP, q = uParamQ, r = uParamR, s = max(uParamS, 1e-4);
  float det = p * s - q * r;
  if (abs(det) < 1e-4) det = sign(det + 1e-9) * 1e-4; // avoid singular map

  int maxIter = int(clamp(uIterations, 20.0, 240.0));
  float bail = max(uBailout, 2.0);
  vec2 z = vec2(0.0, 0.0);
  float iter = 0.0;
  for (int i = 0; i < 240; i++) {
    if (i >= maxIter) break;
    // Möbius transform then square + c.
    vec2 m = cdiv(vec2(p * z.x + q, p * z.y), vec2(r * z.x + s, r * z.y));
    z = cmul(m, m) + c;
    float r2 = dot(z, z);
    if (r2 > bail * bail) break;
    // Guard against sticking near the pole.
    float pole = dot(vec2(r * z.x + s, r * z.y), vec2(r * z.x + s, r * z.y));
    if (pole < 1e-8) break;
    iter += 1.0;
  }

  float t = iter / float(maxIter);
  vec3 color = palette(fract(t * 3.7), uColorScheme);
  float interior = smoothstep(0.999, 0.9995, t);
  color = mix(color, color * 0.22, interior);
  float alpha = uTransparentBg > 0.5 ? (interior < 0.5 ? 1.0 : 0.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
