#include <flutter/runtime_effect.glsl>

precision highp float;

// Uniform layout must match julia_dual_module.dart indices exactly.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4  (Mandelbrot pan)
uniform float uZoom;          // 5    (shared zoom)
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uJuliaReal;     // 9
uniform float uJuliaImag;     // 10
uniform float uTransparentBg; // 11

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.7))
    );
  } else if (scheme == 1) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.0))
    );
  } else if (scheme == 2) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}

// Shared escape-time iteration. Returns smooth escape value or -1.0 if inside.
float escapeSmooth(vec2 z, vec2 c, float bailoutSq, int target) {
  const int MAX_ITERS = 500;
  int it = 0;
  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }
  if (it >= target) return -1.0;
  float mag2 = max(1e-12, dot(z, z));
  return float(it) - log2(log2(mag2)) + 4.0;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float halfW   = uResolution.x * 0.5;
  float scale   = min(halfW, uResolution.y);
  float bailoutSq = uBailout * uBailout;
  int   target  = int(clamp(uIterations, 0.0, 500.0));
  int   scheme  = int(uColorScheme);

  float smoothVal;

  if (fragCoord.x < halfW) {
    // ── LEFT: Mandelbrot set ─────────────────────────────────────────────
    // Map left-half pixel to complex plane.
    vec2 panelCoord = vec2(fragCoord.x, fragCoord.y);
    vec2 uv = (panelCoord - vec2(halfW * 0.5, uResolution.y * 0.5)) / max(1.0, scale);
    vec2 c  = uv / max(0.000001, uZoom) + uCenter;
    smoothVal = escapeSmooth(vec2(0.0), c, bailoutSq, target);
  } else {
    // ── RIGHT: Julia set ─────────────────────────────────────────────────
    vec2 jCoord  = vec2(fragCoord.x - halfW, fragCoord.y);
    vec2 uv = (jCoord - vec2(halfW * 0.5, uResolution.y * 0.5)) / max(1.0, scale);
    vec2 z  = uv / max(0.000001, uZoom);
    vec2 c  = vec2(uJuliaReal, uJuliaImag);
    smoothVal = escapeSmooth(z, c, bailoutSq, target);
  }

  if (smoothVal < 0.0) {
    // Inside set.
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0);
  t = fract(t + uTime * 0.0001);
  vec3 col = palette(t, scheme);

  // Divider line: 1px white border between panels.
  float dx = abs(fragCoord.x - halfW);
  if (dx < 0.75) col = vec3(1.0);

  fragColor = vec4(linearToSRGB(col), 1.0);
}
