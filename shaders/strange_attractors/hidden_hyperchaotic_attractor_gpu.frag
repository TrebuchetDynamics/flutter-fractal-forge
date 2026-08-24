#include <flutter/runtime_effect.glsl>

precision highp float;

// Hidden / hyperchaotic attractor gallery.
// Renders orbit density of a hyperchaotic hidden-attractor system (Matouk's
// family, projected to 2D). Unlike self-excited attractors (Lorenz, Sprott),
// hidden attractors have no unstable equilibrium in their basin — the orbit
// is integrated from a fixed interior seed and colored by visit density,
// matching the phase-space scaling pattern of the existing Sprott modules.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uVariant;       // 10 (0=Matouk A, 1=Matouk B blend)
uniform float uDwell;         // 11 (orbit integration steps per pixel)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
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
  vec2 p = uv / max(uZoom, 0.0001) + uCenter;

  // Each pixel seeds a nearby initial condition; phase-space scaling similar
  // to the Sprott modules (attractor spans a wider range than the viewport).
  const float PHASE_SCALE = 8.0;
  float x = p.x * PHASE_SCALE;
  float y = p.y * PHASE_SCALE;
  float z = 0.1;
  float w = 0.1;

  int variant = int(clamp(floor(uVariant + 0.5), 0.0, 1.0));
  // Matouk-family hyperchaotic coefficients (blended variant).
  float a1 = variant == 0 ? 24.0 : 18.0;
  float a2 = variant == 0 ? 6.0 : 4.5;
  float a3 = variant == 0 ? 8.0 : 5.5;

  const float dt = 0.004;
  int steps = int(clamp(uDwell, 8.0, 96.0));
  int target = int(clamp(uIterations, 20.0, 240.0));
  float bailoutSq = max(4.0, uBailout * uBailout);

  float orbit = 0.0;
  int it = target;
  for (int i = 0; i < 240; i++) {
    if (i >= target) break;
    for (int s = 0; s < 96; s++) {
      if (s >= steps) break;
      // 4D hyperchaotic hidden-attractor flow (Matouk-style):
      //   x' = a1(y - x) + w
      //   y' = x z + a2 y
      //   z' = -a3 z + x y
      //   w' = -x - 0.5 w
      float dx = a1 * (y - x) + w;
      float dy = x * z + a2 * y;
      float dz = -a3 * z + x * y;
      float dw = -x - 0.5 * w;
      x += dt * dx;
      y += dt * dy;
      z += dt * dz;
      w += dt * dw;
    }
    float r2 = x * x + y * y;
    orbit += exp(-0.6 * r2) + 0.08 * exp(-0.35 * abs(z));
    if (r2 > bailoutSq * 100.0) { it = i + 1; break; }
  }

  if (it >= target) {
    float t = fract((orbit / float(target)) * 2.2 + 0.1 * atan(y, x) + uTime * 0.00004);
    vec3 col = palette(t, uColorScheme);
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float r2 = max(1e-10, x * x + y * y + z * z + w * w);
  float smoothVal = float(it) - log2(log2(r2 + 1.0));
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, uColorScheme)), 1.0);
}
