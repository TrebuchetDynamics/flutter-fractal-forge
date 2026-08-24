#include <flutter/runtime_effect.glsl>

precision highp float;

// Escape-time log-polar tessellation.
//
// The last bounded iterate is converted into texture-style coordinates:
//   u = argument(z) / tau
//   v = 2 * (log(bailoutRadius) - log(|z|)) / log(bailoutRadius)
// Repeating an original procedural 2:1 motif in those coordinates creates the
// nested image-tessellation effect without bundling third-party image assets.
uniform float uTime;          // 0 (intentionally unused: static/accessibility-safe)
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7 (escape radius)
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uFormula;       // 10: 0 Mandelbrot, 1 Julia, 2 Burning Ship, 3 Tricorn
uniform float uMotif;         // 11: 0 eye, 1 mask, 2 feline glyph, 3 serpent
uniform float uJuliaReal;     // 12
uniform float uJuliaImag;     // 13
uniform float uAngularRepeats;// 14
uniform float uRadialRepeats; // 15
uniform float uPhaseOffset;   // 16

out vec4 fragColor;

const float PI = 3.14159265358979323846;
const float TAU = 6.28318530717958647692;

vec2 complexSquare(vec2 z) {
  return vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

vec3 palette(float t, float schemeValue) {
  float scheme = clamp(floor(schemeValue + 0.5), 0.0, 63.0);
  vec3 a = 0.48 + 0.10 * sin(vec3(1.0, 1.7, 2.3) * (0.31 * scheme + 0.2));
  vec3 b = 0.38 + 0.16 * cos(vec3(1.3, 1.9, 2.7) * (0.23 * scheme + 0.4));
  vec3 c = 0.85 + 0.55 * sin(vec3(0.7, 1.1, 1.5) * (0.17 * scheme + 0.6));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (scheme + 1.0)) * 43758.5453);
  return clamp(a + b * cos(TAU * (c * t + d)), 0.015, 0.92);
}

float ellipseMask(vec2 p, vec2 radii, float softness) {
  float d = length(p / radii);
  return 1.0 - smoothstep(1.0 - softness, 1.0 + softness, d);
}

vec3 proceduralMotif(vec2 uv, int motif, vec3 base, vec3 accent) {
  // A 2:1 tile: q spans [-1,1] horizontally and [-0.5,0.5] vertically.
  vec2 q = (uv - 0.5) * vec2(2.0, 1.0);
  float aa = 0.035;
  float body = 0.0;
  float ink = 0.0;
  float highlight = 0.0;

  if (motif == 0) {
    // Eye glyph.
    body = ellipseMask(q, vec2(0.86, 0.34), aa);
    float iris = ellipseMask(q, vec2(0.29, 0.29), aa);
    float pupil = ellipseMask(q, vec2(0.105, 0.19), aa);
    float glint = ellipseMask(q - vec2(-0.08, 0.09), vec2(0.045), aa);
    ink = max(iris * 0.78, pupil);
    highlight = glint;
  } else if (motif == 1) {
    // Abstract theatrical mask.
    body = ellipseMask(q, vec2(0.72, 0.46), aa);
    float eyeL = ellipseMask(q - vec2(-0.27, 0.10), vec2(0.15, 0.09), aa);
    float eyeR = ellipseMask(q - vec2(0.27, 0.10), vec2(0.15, 0.09), aa);
    vec2 smileQ = (q - vec2(0.0, -0.03)) / vec2(0.48, 0.28);
    float smile = 1.0 - smoothstep(0.055, 0.11, abs(length(smileQ) - 1.0));
    smile *= step(q.y, -0.03);
    ink = max(max(eyeL, eyeR), smile);
    highlight = ellipseMask(q - vec2(-0.25, 0.28), vec2(0.09, 0.045), aa);
  } else if (motif == 2) {
    // Original feline-like glyph made only from analytic shapes.
    body = ellipseMask(q - vec2(0.0, -0.03), vec2(0.62, 0.43), aa);
    float earL = ellipseMask(q - vec2(-0.43, 0.35), vec2(0.23, 0.27), aa);
    float earR = ellipseMask(q - vec2(0.43, 0.35), vec2(0.23, 0.27), aa);
    body = max(body, max(earL, earR));
    float eyeL = ellipseMask(q - vec2(-0.23, 0.08), vec2(0.10, 0.055), aa);
    float eyeR = ellipseMask(q - vec2(0.23, 0.08), vec2(0.10, 0.055), aa);
    float nose = ellipseMask(q - vec2(0.0, -0.05), vec2(0.07, 0.05), aa);
    float whiskers = 1.0 - smoothstep(0.018, 0.045,
        min(abs(q.y + 0.12 + 0.10 * q.x), abs(q.y + 0.12 - 0.10 * q.x)));
    whiskers *= step(0.18, abs(q.x));
    ink = max(max(eyeL, eyeR), max(nose, whiskers));
    highlight = ellipseMask(q - vec2(-0.19, 0.10), vec2(0.025), aa);
  } else {
    // Sinuous serpent ribbon with an analytic scale pattern.
    float centerline = 0.18 * sin(TAU * (q.x * 0.5 + 0.08));
    float ribbon = 1.0 - smoothstep(0.12, 0.17, abs(q.y - centerline));
    float head = ellipseMask(q - vec2(0.67, centerline), vec2(0.25, 0.18), aa);
    body = max(ribbon, head);
    float scales = 0.5 + 0.5 * cos(TAU * (3.0 * q.x + 2.0 * q.y));
    ink = body * smoothstep(0.42, 0.66, scales);
    float eye = ellipseMask(q - vec2(0.74, centerline + 0.055), vec2(0.035), aa);
    highlight = eye;
  }

  vec3 paper = base * (0.16 + 0.16 * (1.0 - body));
  vec3 fill = mix(base * 0.58, accent * 0.88, 0.42 + 0.28 * uv.y);
  vec3 color = mix(paper, fill, body);
  color = mix(color, base * 0.055, ink);
  color = mix(color, vec3(0.94), highlight * 0.75);
  return clamp(color, 0.0, 0.94);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = max(1.0, min(uResolution.x, uResolution.y));
  vec2 p = (fragCoord - 0.5 * uResolution) / scale;
  p = p / max(uZoom, 0.0001) * 3.25 + uCenter;

  int formula = int(clamp(floor(uFormula + 0.5), 0.0, 3.0));
  vec2 c = formula == 1 ? vec2(uJuliaReal, uJuliaImag) : p;
  vec2 z = formula == 1 ? p : vec2(0.0);
  vec2 lastBounded = z;
  float minOrbit = 1e20;
  float bailoutRadius = max(uBailout, 1.0001);
  float bailoutSquared = bailoutRadius * bailoutRadius;
  int maxIterations = int(clamp(uIterations, 1.0, 300.0));
  bool escaped = false;

  for (int i = 0; i < 300; i++) {
    if (i >= maxIterations) break;
    lastBounded = z;
    vec2 iterZ = z;
    if (formula == 2) {
      iterZ = abs(iterZ);
    } else if (formula == 3) {
      iterZ.y = -iterZ.y;
    }
    z = complexSquare(iterZ) + c;
    float metric = dot(z, z);
    minOrbit = min(minOrbit, metric);
    // The negated comparison also treats NaN/Infinity as escaped while the
    // retained lastBounded sample remains finite.
    if (!(metric <= bailoutSquared)) {
      escaped = true;
      break;
    }
  }

  if (!escaped) {
    float interiorTone = 0.035 + 0.045 / (1.0 + sqrt(max(minOrbit, 0.0)));
    vec3 interior = palette(0.08, uColorScheme) * interiorTone;
    float alpha = uTransparentBg > 0.5 ? 0.0 : 1.0;
    fragColor = vec4(interior, alpha);
    return;
  }

  // Use the last bounded iterate. Sampling the already-escaped z collapses the
  // logarithmic radius to one edge and produces an unstable bright seam.
  float boundedMetric =
      clamp(dot(lastBounded, lastBounded), 0.000001, bailoutSquared);
  float logEscape = max(log(bailoutRadius), 0.000001);
  float radial =
      2.0 * (logEscape - 0.5 * log(boundedMetric)) / logEscape;
  radial = clamp(radial, 0.0, 0.999999);
  float angular = atan(lastBounded.y, lastBounded.x) / TAU + 0.5;

  float radialRepeats = clamp(floor(uRadialRepeats + 0.5), 1.0, 16.0);
  float angularRepeats = clamp(floor(uAngularRepeats + 0.5), 1.0, 12.0);
  float row = floor(radial * radialRepeats);
  float stagger = 0.5 * mod(row, 2.0);
  vec2 tileUV = vec2(
    fract(angular * angularRepeats + uPhaseOffset + stagger),
    fract(radial * radialRepeats)
  );

  float colorPhase = fract(angular + radial * 0.31);
  vec3 base = palette(colorPhase, uColorScheme);
  vec3 accent = palette(fract(colorPhase + 0.37), uColorScheme + 11.0);
  int motif = int(clamp(floor(uMotif + 0.5), 0.0, 3.0));
  vec3 color = proceduralMotif(tileUV, motif, base, accent);

  // A restrained boundary shade preserves the set silhouette without temporal
  // animation or full-screen luminance pulses.
  float boundaryShade = 0.72 + 0.28 * smoothstep(0.0, 0.18, radial);
  color *= boundaryShade;
  float alpha = uTransparentBg > 0.5 ? 0.92 : 1.0;
  fragColor = vec4(color, alpha);
}
