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
  int scheme = int(uColorScheme);

  // Driver-friendly fixed loop + orbit trap accumulators.
  const int MAX_ITERS = 500;
  int it = 0;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  float minDistSq  = 1e9; // scheme 10: point trap at origin
  float crossDist  = 1e9; // scheme 11: cross trap (min |Re(z)| or |Im(z)|)

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // z = z^2 + c
    z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

    // Orbit trap accumulators (always updated, cheap).
    float dSq = dot(z, z);
    minDistSq = min(minDistSq, dSq);
    crossDist = min(crossDist, min(abs(z.x), abs(z.y)));

    if (dSq > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  // Orbit trap coloring (schemes 10-11): colour all points, ignore set membership.
  if (scheme == 10) {
    // Point trap at origin: colour by closest approach distance.
    float d = clamp(sqrt(minDistSq) / uBailout, 0.0, 1.0);
    float t = fract(d * 3.0 + uTime * 0.0001);
    fragColor = vec4(linearToSRGB(palette(t, 0)), 1.0);
    return;
  }
  if (scheme == 11) {
    // Cross trap: colour by closest approach to real or imaginary axis.
    float d = clamp(crossDist * 4.0, 0.0, 1.0);
    float t = fract(d * 2.0 + uTime * 0.0001);
    fragColor = vec4(linearToSRGB(palette(t, 1)), 1.0);
    return;
  }

  if (it >= target) {
    // Inside set (standard escape-time modes).
    if (uTransparentBg > 0.5) fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    else fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;
  float t = fract(smoothVal / 64.0);
  t = fract(t + uTime * 0.0001);

  vec3 col;
  if (uCustomStopCount > 0.5) col = sampleCustomPalette(t);
  else col = palette(t, scheme);

  fragColor = vec4(linearToSRGB(col), 1.0);
}
