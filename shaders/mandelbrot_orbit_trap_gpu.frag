#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbrot Orbit Trap (Cross Trap)
// Instead of coloring by escape-iteration count, colors by the minimum
// distance the orbit comes to the real and imaginary axes (the "cross trap").
// Both interior (bounded) and exterior (escaped) pixels are colored by this
// trap distance, revealing rich structure inside the classic black interior.
// Interior pixels are shown at 60% brightness to distinguish the boundary.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.4)),0.5+0.5*cos(6.28318*(t+0.7)));
  } else if (scheme == 1) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.5)),0.5+0.5*cos(6.28318*(t+0.3)),0.5+0.5*cos(6.28318*(t+0.0)));
  } else if (scheme == 2) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.33)),0.5+0.5*cos(6.28318*(t+0.67)));
  } else if (scheme == 3) {
    float g = 0.5+0.5*cos(6.28318*t); return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37*s+0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29*s+0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c*t+d)), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c   = uv / max(0.000001, uZoom) + uCenter;
  vec2 z   = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  // Cross trap: record minimum distance to real axis and imaginary axis.
  float trap = 1e10;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    z = vec2(z.x*z.x - z.y*z.y + c.x, 2.0*z.x*z.y + c.y);

    // Distance to nearest axis (cross trap).
    float d = min(abs(z.x), abs(z.y));
    trap = min(trap, d);

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  bool escaped = (it < target);

  if (!escaped && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Map trap distance to color band using log scale for even banding.
  // trap ∈ [0, ~uBailout]; log maps this to (-∞, ~log(uBailout)].
  // Divide by 3 for ~3-band spread at default zoom.
  float logTrap = -log(max(trap, 1e-20)) / 3.0;
  float t = fract(logTrap + uTime * 0.0001);

  vec3 col = palette(t, schemeInt);

  // Interior (bounded orbit): darken to distinguish from exterior.
  if (!escaped) col *= 0.55;

  fragColor = vec4(linearToSRGB(col), 1.0);
}
