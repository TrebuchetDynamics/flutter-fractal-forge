#include <flutter/runtime_effect.glsl>

precision highp float;

// Bessel-function zero field.
// The Bessel function J_nu(z) of complex argument has zeros that form a
// striking near-regular lattice in the complex plane. We evaluate J_nu(z)
// with its power series via the term recurrence
//   term_{k+1} = term_k * (-z^2/4) / ((k+1) * (k+nu+1)),
// avoiding factorials, and render magnitude / phase / zero-distance fields.
// Evidence: 7th-wave seeds and the eighth-wave backlog ("Bessel-function
// fractal fields").
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (series terms)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uOrder;         // 10 (Bessel order nu)
uniform float uMode;          // 11 (0=magnitude, 1=phase, 2=zeros)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

// J_nu(z) via the ascending series with the term recurrence.
vec2 besselJ(float nu, vec2 z, int terms) {
  // First term: (z/2)^nu / Gamma(nu+1). For integer-ish nu we use the
  // small-z expansion: compute (z/2)^nu by polar power and Gamma via
  // Lanczos-truncated product for nu in [0, 6].
  float r = length(z) * 0.5;
  float phi = atan(z.y, z.x);
  float pr = pow(max(r, 1e-12), nu);
  vec2 first = vec2(pr * cos(nu * phi), pr * sin(nu * phi));

  // Gamma(nu+1) for nu in [0,6]: shift to Gamma(x), x in [1,7], via
  // Stirling with reflection for small x — sufficient for shading.
  float x = nu + 1.0;
  float g;
  if (x < 1.0) {
    g = 1.0 / x; // Gamma(x+1)/x = Gamma(x) near 1 (nu >= 0 keeps x >= 1)
  } else {
    // Stirling series for x >= 1.
    float lx = log(x);
    g = sqrt(6.28318 / x) * pow(x / 2.718281828, x) *
        (1.0 + 1.0 / (12.0 * x) + 1.0 / (288.0 * x * x));
  }
  first /= max(g, 1e-12);

  // Series: sum_k term_k, term_0 = first,
  // term_{k+1} = term_k * (-z^2/4) / ((k+1)(k+nu+1)).
  vec2 zs = z * z * -0.25;
  vec2 term = first;
  vec2 sum = first;
  for (int k = 0; k < 32; k++) {
    if (k >= terms) break;
    float denom = float(k + 1) * (float(k) + nu + 1.0);
    term = cmul(term, zs) / max(denom, 1e-12);
    sum += term;
  }
  return sum;
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
  vec2 z = uv * 30.0 / max(uZoom, 0.0001) + uCenter;

  float nu = clamp(uOrder, 0.0, 6.0);
  int terms = int(clamp(uIterations, 8.0, 32.0));
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 2.0));

  vec2 j = besselJ(nu, z, terms);
  float mag = length(j);
  float phase = atan(j.y, j.x);

  vec3 color;
  if (mode == 0) {
    // Magnitude field: log-scaled with zero-lattice darkening.
    float lm = log(max(mag, 1e-9) + 1.0);
    color = palette(fract(lm * 0.55 + 0.1), uColorScheme) *
            (0.2 + 0.8 * clamp(lm * 0.8, 0.0, 1.0));
  } else if (mode == 1) {
    // Phase field: argument of J_nu(z), smooth cyclic bands.
    color = palette(fract(phase / 6.28318 + 0.5), uColorScheme);
  } else {
    // Zero-distance view: bright ridges near the zeros of J_nu.
    float near0 = exp(-3.0 * mag);
    color = palette(fract(near0 * 0.8 + 0.35 * phase / 6.28318), uColorScheme) *
            (0.15 + 1.1 * near0);
  }

  float alpha = uTransparentBg > 0.5 ? clamp(color.g + 0.35, 0.3, 1.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
