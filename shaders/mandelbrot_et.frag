#include <flutter/runtime_effect.glsl>

precision highp float;

// IMPORTANT: Uniform layout must match Dart UniformSchema exactly.
uniform float uTime;           // 0
uniform vec2  uResolution;     // 1-2
uniform vec2  uCenter;         // 3-4
uniform float uZoom;           // 5
uniform float uIterations;     // 6
uniform float uBailout;        // 7
uniform float uColorScheme;    // 8
uniform float uTransparentBg;  // 9

uniform float uCustomStopCount; // 10
uniform vec4  uCustomStop0;     // 11-14 (rgb + pos in a)
uniform vec4  uCustomStop1;     // 15-18
uniform vec4  uCustomStop2;     // 19-22
uniform vec4  uCustomStop3;     // 23-26
uniform vec4  uCustomStop4;     // 27-30
uniform vec4  uCustomStop5;     // 31-34
uniform vec4  uCustomStop6;     // 35-38
uniform vec4  uCustomStop7;     // 39-42

out vec4 fragColor;

vec3 builtinPalette(float t, int scheme) {
  t = clamp(t, 0.0, 1.0);
  if (scheme == 0) {
    // Fire
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.00)),
      0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.33)),
      0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.67))
    );
  }
  if (scheme == 1) {
    // Ocean
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.50)),
      0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.60)),
      0.5 + 0.5 * cos(6.28318 * (1.0 * t + 0.70))
    );
  }
  if (scheme == 2) {
    // Psychedelic
    return vec3(
      0.5 + 0.5 * sin(6.28318 * t * 3.0),
      0.5 + 0.5 * sin(6.28318 * t * 5.0 + 2.0),
      0.5 + 0.5 * sin(6.28318 * t * 7.0 + 4.0)
    );
  }
  // Grayscale
  return vec3(t);
}

vec3 sampleCustomPalette(float t) {
  t = clamp(t, 0.0, 1.0);

  // Read stops (rgb, pos in a)
  vec4 s0 = uCustomStop0;
  vec4 s1 = uCustomStop1;
  vec4 s2 = uCustomStop2;
  vec4 s3 = uCustomStop3;
  vec4 s4 = uCustomStop4;
  vec4 s5 = uCustomStop5;
  vec4 s6 = uCustomStop6;
  vec4 s7 = uCustomStop7;

  // Find segment manually (avoid arrays/loops that some drivers dislike)
  vec4 a = s0;
  vec4 b = s1;

  if (t <= s0.a) { a = s0; b = s0; }
  else if (t <= s1.a) { a = s0; b = s1; }
  else if (t <= s2.a) { a = s1; b = s2; }
  else if (t <= s3.a) { a = s2; b = s3; }
  else if (t <= s4.a) { a = s3; b = s4; }
  else if (t <= s5.a) { a = s4; b = s5; }
  else if (t <= s6.a) { a = s5; b = s6; }
  else if (t <= s7.a) { a = s6; b = s7; }
  else { a = s7; b = s7; }

  float denom = max(0.0001, b.a - a.a);
  float u = clamp((t - a.a) / denom, 0.0, 1.0);
  return mix(a.rgb, b.rgb, u);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  // Map pixels -> complex plane
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  vec2 z = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  // Driver-friendly fixed loop.
  const int MAX_ITERS = 500;
  int it = 0;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // z = z^2 + c
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    // inside set
    if (uTransparentBg > 0.5) fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    else fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Smooth-ish coloring
  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));
  float t = smoothVal / max(1.0, uIterations);
  t = fract(t + uTime * 0.0001);

  // Debug-friendly coloring: mix palette with a coordinate tint so we can
  // visually confirm we're not outputting all-black.
  vec3 col;
  if (uCustomStopCount > 0.5) col = sampleCustomPalette(t);
  else col = builtinPalette(t, int(uColorScheme));

  // Add a tiny UV-based tint (should be visible even if palette is dark).
  vec2 uv01 = fragCoord / max(uResolution, vec2(1.0));
  col = clamp(col + vec3(0.15 * uv01.x, 0.0, 0.15 * uv01.y), 0.0, 1.0);

  fragColor = vec4(col, 1.0);
}
