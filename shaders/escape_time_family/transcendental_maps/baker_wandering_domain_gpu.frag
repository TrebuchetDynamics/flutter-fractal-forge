#include <flutter/runtime_effect.glsl>

precision highp float;

// Baker / wandering-domain transcendental map.
// Iterates the family z -> lambda + z + tan(z), whose topologically
// hyperbolic members exhibit Baker and wandering domains: nested escaping
// tracts and web-like Julia structure near the tan poles. Escape coloring
// uses log-radius growth (transcendental orbits grow fast).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uLambdaRe;      // 10 (real part of lambda)
uniform float uLambdaIm;      // 11 (imaginary part of lambda)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 ctan(vec2 z) {
  // tan(z) = sin(z)/cos(z); use sin/cos split formulas.
  float s = sin(z.x) * cosh(z.y);
  float c = cos(z.x) * cosh(z.y);
  float ss = cos(z.x) * sinh(z.y);
  float cc = -sin(z.x) * sinh(z.y);
  // (s + i ss) / (c + i cc)
  float den = c * c + cc * cc;
  return vec2((s * c + ss * cc) / max(den, 1e-9), (ss * c - s * cc) / max(den, 1e-9));
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
  vec2 z = uv * 2.0 / max(uZoom, 0.0001) + uCenter;

  vec2 lam = vec2(uLambdaRe, uLambdaIm);
  int maxIter = int(clamp(uIterations, 20.0, 200.0));
  float bail = max(uBailout, 2.0);

  float iter = 0.0;
  float growth = 0.0;
  for (int i = 0; i < 200; i++) {
    if (i >= maxIter) break;
    vec2 t = ctan(z);
    z = lam + z + t;
    float r2 = dot(z, z);
    float lr = 0.5 * log(max(r2, 1e-12));
    if (lr > log(bail) * 4.0) break;
    growth = lr;
    iter += 1.0;
  }

  float t = iter / float(maxIter);
  vec3 color = palette(fract(t * 4.3 + growth * 0.12), uColorScheme);
  float interior = smoothstep(0.999, 0.9995, t);
  color = mix(color, color * 0.16, interior);
  float alpha = uTransparentBg > 0.5 ? (interior < 0.5 ? 1.0 : 0.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
