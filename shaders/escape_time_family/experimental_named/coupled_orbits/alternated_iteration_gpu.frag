#include <flutter/runtime_effect.glsl>

precision highp float;

// Alternated Iteration Fractal — switches between two quadratic maps each step.
// Even steps: z = z^2 + c1  (c1 = pixel coordinate, Mandelbrot-style)
// Odd  steps: z = z^2 + c2  (c2 from extra params)
// This creates hybrid attractors blending two Mandelbrot-type dynamics.
// Derivative tracks both maps for correct normal-map shading.
// Extra params: uC2Real (float 10), uC2Imag (float 11).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uC2Real;        // 10  (Re(c2), default 0.0, range -2..2)
uniform float uC2Imag;        // 11  (Im(c2), default 0.0, range -2..2)

out vec4 fragColor;

// Shared: linearToSRGB, palette (color.glsl), cmul (complex.glsl)
#include "../../../shared/color.glsl"
#include "../../../shared/complex.glsl"

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c1 = uv / max(0.000001, uZoom) + uCenter;  // pixel → c1
  vec2 c2 = vec2(uC2Real, uC2Imag);                // user param → c2

  vec2  z   = vec2(0.0);
  // Complex derivative dz/dc1 for normal-map shading.
  // Even step: z = z^2 + c1 → der = 2z*der + 1
  // Odd  step: z = z^2 + c2 → der = 2z*der  (c2 is constant w.r.t. c1)
  vec2  der = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Derivative: d(z^2+c)/dc1 = 2z * der + (1 if even, 0 if odd)
    der = 2.0 * cmul(z, der);
    if (j - 2 * (j / 2) == 0) {
      // Even step: z = z^2 + c1, derivative gets +1
      der += vec2(1.0, 0.0);
      z = cmul(z, z) + c1;
    } else {
      // Odd step: z = z^2 + c2, no extra derivative term
      z = cmul(z, z) + c2;
    }

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2      = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
