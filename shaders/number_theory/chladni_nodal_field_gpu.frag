#include <flutter/runtime_effect.glsl>

precision highp float;

// Chladni Nodal Field — clean-room, single-pass standing-wave shader.
//
// A thin plate driven at a resonant mode has nodal lines where the standing
// wave vanishes. Superposing modal pairs
//     cos(n*pi*x)*cos(m*pi*y) - cos(m*pi*x)*cos(n*pi*y)
// with 1/k weights gives the classic Chladni figure; displacing the fine modes
// by a coarse field nests plate figures inside plate figures, which is what
// makes the image fractal rather than ornamental. It is a wave-field image like
// the Talbot carpet and diffraction entries, not an escape-time map.

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;     // modal count
uniform float uBailout;        // unused, kept for the shared ABI
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uWarpAmount;
uniform float uNodeSharpness;

out vec4 fragColor;

const float PI = 3.14159265359;
const int MAX_MODES = 40;

// IEC 61966-2-1 sRGB transfer function (linear -> display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

// Cohesive ink -> deep blue -> violet -> magenta -> gold -> warm white ramp.
// Scheme 0 uses it directly so the field keeps a dark background and luminous
// crests instead of the flat mid-tones a bare cosine palette produces.
vec3 inkRamp(float t) {
  t = clamp(t, 0.0, 1.0);
  vec3 c = mix(vec3(0.010, 0.014, 0.030), vec3(0.055, 0.115, 0.300), smoothstep(0.00, 0.16, t));
  c = mix(c, vec3(0.230, 0.150, 0.470), smoothstep(0.16, 0.36, t));
  c = mix(c, vec3(0.760, 0.250, 0.440), smoothstep(0.36, 0.56, t));
  c = mix(c, vec3(0.980, 0.640, 0.260), smoothstep(0.56, 0.78, t));
  c = mix(c, vec3(1.000, 0.960, 0.840), smoothstep(0.78, 1.00, t));
  return c;
}

vec3 schemeColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return inkRamp(t);
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.45), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return mix(inkRamp(t), clamp(iqPalette(t, a, b, c, d), 0.0, 1.0), 0.55);
}

float modalPair(vec2 p, float n, float m) {
  return cos(n * PI * p.x) * cos(m * PI * p.y)
       - cos(m * PI * p.x) * cos(n * PI * p.y);
}

// Rational soft saturation; avoids relying on tanh() in the fragment path.
float softSat(float x) {
  return x / (1.0 + abs(x));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv * 2.0 / max(0.000001, uZoom) + uCenter;

  float drift = uTime * 0.00003;
  int modes = int(clamp(uIterations, 6.0, float(MAX_MODES)));

  // Coarse field: five low-order modal pairs. It only reshapes the fine field,
  // so it stays cheap and keeps the large-scale plate figure readable.
  float coarse = 0.0;
  for (int k = 0; k < 5; k++) {
    float n = float(k) + 1.0;
    float m = 2.0 * float(k) + 3.0;
    coarse += modalPair(p, n, m) / (float(k) + 1.0);
  }

  vec2 q = p + clamp(uWarpAmount, 0.0, 0.6) * softSat(coarse * 0.8);

  float fine = 0.0;
  for (int k = 0; k < MAX_MODES; k++) {
    if (k >= modes) break;
    float n = float(k) + 1.0;
    float m = 3.0 * float(k) + 5.0;
    float detune = 1.0 + 0.06 * sin(drift * 6.28318 + float(k) * 0.7);
    fine += modalPair(q * detune, n, m) / pow(float(k) + 1.0, 0.85);
  }

  float sharp = clamp(uNodeSharpness, 6.0, 90.0);
  float node = exp(-abs(fine) * sharp);
  float band = exp(-abs(fine) * sharp * 0.09) - node;

  float body = 0.26 + 0.18 * softSat(coarse * 0.6) + 0.34 * node;
  vec3 color = schemeColor(body, int(uColorScheme));
  color *= 0.10 + 0.42 * band + 1.15 * node;

  if (band + node < 0.015 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
