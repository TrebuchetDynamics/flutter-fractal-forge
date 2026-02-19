#include <flutter/runtime_effect.glsl>

precision highp float;

// Wang-Sun-Cang attractor (2010) — a=0.2, b=0.01, c=−0.4, d=0.5.
// dx/dt = ay + bxz
// dy/dt = cx + dy²
// dz/dt = xz − z² − x²
// Reported by Wang, Sun & Cang (2010). The dy² term in the y-equation and
// the quadratic xz−z²−x² restoring force in z create a complex asymmetric
// attractor with a characteristic tilted double-scroll. Despite small b,
// the xz product seeds chaotic switching between the two scroll centres.
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  float x = p.x;
  float y = p.y;
  float z = 0.1 * sin(0.0013 * uTime) + 0.05 * p.x;

  const float a_p =  0.2;
  const float b_p =  0.01;
  const float c_p = -0.4;
  const float d_p =  0.5;
  const float dt  =  0.02;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailoutSq = max(9.0, uBailout * uBailout);
  int it = target;
  float orbit = 0.0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;
    float dx = a_p*y + b_p*x*z;
    float dy = c_p*x + d_p*y*y;
    float dz = x*z - z*z - x*x;
    x += dt * dx;
    y += dt * dy;
    z += dt * dz;
    float r2 = x*x + y*y + z*z;
    orbit += exp(-0.20 * (x*x + z*z)) + 0.07 * exp(-0.5 * y*y);
    if (r2 > bailoutSq) { it = i + 1; break; }
  }

  if (it >= target) {
    float t = fract((orbit / float(target)) * 1.8 + 0.07 * atan(y, x) + uTime * 0.00005);
    fragColor = vec4(linearToSRGB(getPaletteColor(t, int(uColorScheme))), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }
  float r2 = max(1e-10, x*x + y*y + z*z);
  float smoothVal = float(it) - log2(log2(r2 + 1.0));
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(getPaletteColor(t, int(uColorScheme))), 1.0);
}
