#include <flutter/runtime_effect.glsl>

precision highp float;

// Herman-ring / toral-band Fatou visualizer.
// Iterates a degree-3 rational map
//   f(z) = lam * z^2 * (z - a) / (1 - a z),   lam = e^(2pi i theta)
// which for suitable rotation theta and |a|<1 has invariant annular (toral)
// Fatou components bounded by Herman rings, distinct from Siegel disks.
// Colored by escape iteration plus a ring-phase channel.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uTheta;         // 10 (rotation, turns)
uniform float uA;             // 11 (|a| < 1 circle-inversion parameter)

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
  vec2 z = uv * 3.0 / max(uZoom, 0.0001) + uCenter;

  float theta = uTheta * 6.28318;
  float aa = clamp(uA, 0.0, 0.9);
  vec2 lam = vec2(cos(theta), sin(theta));

  int maxIter = int(clamp(uIterations, 20.0, 240.0));
  float bail = max(uBailout, 2.0);
  float iter = 0.0;
  for (int i = 0; i < 240; i++) {
    if (i >= maxIter) break;
    vec2 z2 = cmul(z, z);
    vec2 z3 = cmul(z2, z);
    vec2 num = (z3 - aa * z2);            // z^2 (z - a)
    vec2 den = vec2(1.0 - aa * z.x, -aa * z.y); // 1 - a z
    z = cmul(lam, cdiv(num, den));
    if (dot(z, z) > bail * bail) break;
    if (dot(den, den) < 1e-8) break;
    iter += 1.0;
  }

  float t = iter / float(maxIter);
  // Ring phase: how many times the orbit winds around the axis.
  float ring = fract(atan(uv.y, uv.x) / 6.28318);
  vec3 base = palette(fract(t * 3.0), uColorScheme);
  vec3 band = palette(fract(ring + t * 0.6), uColorScheme);
  vec3 color = mix(base, band, 0.5 + 0.5 * smoothstep(0.2, 0.8, t));
  float interior = smoothstep(0.999, 0.9995, t);
  color = mix(color, color * 0.18, interior);
  float alpha = uTransparentBg > 0.5 ? (interior < 0.5 ? 1.0 : 0.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
