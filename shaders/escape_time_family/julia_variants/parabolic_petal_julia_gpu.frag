#include <flutter/runtime_effect.glsl>

precision highp float;

// Parabolic petal (Leau-Fatou flower) Julia visualizer.
// At a parabolic fixed point the multiplier is a root of unity and the
// dynamics form attracting/repelling petals (Leau-Fatou flowers). This module
// iterates z_{n+1} = z + lam * z^2 + c near a parabolic parameter and colors
// by (a) escape iteration into the petals and (b) the petal angle strata.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uPetals;        // 10 (number of petals, 2-8)
uniform float uRotation;      // 11 (rotation number phase)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
vec2 cadd(vec2 a, vec2 b) { return vec2(a.x + b.x, a.y + b.y); }

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
  int petals = int(clamp(floor(uPetals + 0.5), 2.0, 8.0));
  float rot = uRotation * 6.28318;
  // Parabolic multiplier: lam = e^(i * rotation phase).
  vec2 lam = vec2(cos(rot), sin(rot));

  int maxIter = int(clamp(uIterations, 20.0, 240.0));
  float bail = max(uBailout, 2.0);
  vec2 z = vec2(0.0, 0.0);
  float iter = 0.0;
  vec2 last = z;
  for (int i = 0; i < 240; i++) {
    if (i >= maxIter) break;
    vec2 z2 = cmul(z, z);
    z = z + cmul(lam, z2) + c; // parabolic (z -> z + lam z^2 + c)
    float d = dot(z - last, z - last);
    last = z;
    float r2 = dot(z, z);
    if (r2 > bail * bail) break;
    if (d < 1e-14 && i > 20) break; // converged to parabolic point
    iter += 1.0;
  }

  float t = iter / float(maxIter);
  // Petal strata by angle of the escaping path.
  float petalAngle = fract(atan(z.y, z.x) / 6.28318 * float(petals) + 0.5);
  vec3 base = palette(fract(t * 3.3), uColorScheme);
  vec3 petal = palette(fract(petalAngle + t * 0.5), uColorScheme);
  vec3 color = mix(base, petal, 0.5 + 0.5 * smoothstep(0.0, 0.6, t));
  float interior = smoothstep(0.999, 0.9995, t);
  color = mix(color, color * 0.22, interior);
  float alpha = uTransparentBg > 0.5 ? (interior < 0.5 ? 1.0 : 0.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
