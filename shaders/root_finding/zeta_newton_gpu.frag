#include <flutter/runtime_effect.glsl>

precision highp float;

// Riemann Zeta Newton Basins.
//   s_{k+1} = s_k - zeta(s_k) / zeta'(s_k)
// Colour by which zero the iteration falls into, blended with how quickly it
// got there.
//
// zeta is evaluated through the Dirichlet eta (alternating) series
//   eta(s) = sum_{n>=1} (-1)^(n-1) n^(-s)
//   zeta(s) = eta(s) / (1 - 2^(1-s))
// The plain series sum n^(-s) only converges for Re(s) > 1, which excludes the
// critical strip 0 < Re(s) < 1 where every nontrivial zero lives. The
// alternating form converges for Re(s) > 0, so the basins around the zeros on
// the critical line are the real thing rather than an artefact of a divergent
// sum.
//
// Derivatives, with A = eta(s) and B = 1 - 2^(1-s):
//   A'(s) = -sum (-1)^(n-1) log(n) n^(-s)
//   B'(s) = log(2) * 2^(1-s)
//   zeta' = (A'B - AB') / B^2
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uTerms;         // 10  series terms (8..48)

out vec4 fragColor;

const float LN2 = 0.6931471805599453;

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

vec3 palette(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cdiv(vec2 a, vec2 b) {
  float d = max(1e-30, dot(b, b));
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

// n^(-s) = exp(-s log n)
vec2 npow(float lnN, vec2 s) {
  float amp = exp(-s.x * lnN);
  float ph = -s.y * lnN;
  return amp * vec2(cos(ph), sin(ph));
}

// Returns zeta(s) in .xy and zeta'(s) in .zw.
vec4 zetaAndDeriv(vec2 s, int terms) {
  vec2 A = vec2(0.0);   // eta(s)
  vec2 Ad = vec2(0.0);  // eta'(s)
  float sign = 1.0;
  for (int n = 1; n <= 48; n++) {
    if (n > terms) break;
    float lnN = log(float(n));
    vec2 term = npow(lnN, s);
    A += sign * term;
    Ad -= sign * lnN * term;
    sign = -sign;
  }

  // B = 1 - 2^(1-s),  B' = log(2) * 2^(1-s)
  float ampB = exp((1.0 - s.x) * LN2);
  float phB = -s.y * LN2;
  vec2 two1ms = ampB * vec2(cos(phB), sin(phB));
  vec2 B = vec2(1.0, 0.0) - two1ms;
  vec2 Bd = LN2 * two1ms;

  vec2 zeta = cdiv(A, B);
  // zeta' = (A'B - A B') / B^2
  vec2 num = cmul(Ad, B) - cmul(A, Bd);
  vec2 zetaD = cdiv(num, cmul(B, B));
  return vec4(zeta, zetaD);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  int terms = int(clamp(uTerms, 8.0, 48.0));

  // Frame the critical strip: x is Re(s) around 1/2, y is Im(s).
  vec2 s = vec2(uv.x, uv.y) / max(0.000001, uZoom) + uCenter;

  const int MAX_ITERS = 200;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float tol = max(1e-6, uBailout * 1e-5);

  int it = target;
  float lastMag = 1.0;
  for (int k = 0; k < MAX_ITERS; k++) {
    if (k >= target) break;
    vec4 zd = zetaAndDeriv(s, terms);
    vec2 f = zd.xy;
    vec2 fp = zd.zw;
    lastMag = length(f);
    if (lastMag < tol) { it = k; break; }
    if (dot(fp, fp) < 1e-24) { it = k; break; }  // stationary point
    vec2 step = cdiv(f, fp);
    s -= step;
    // A Newton step can throw the iterate a long way; keep it finite so the
    // frame does not fill with NaN.
    if (!(dot(s, s) < 1e12)) { it = k; break; }
  }

  // The zeros sit at 1/2 +/- i t_k, so the imaginary part of the landing point
  // identifies which basin this pixel fell into.
  float basin = s.y * 0.08;
  // No smooth-iteration term here: the usual log(log|z|)/log(degree) formula
  // assumes a fixed polynomial degree, and zeta has none.
  float speed = float(it) / float(target);

  int baseScheme = schemeInt >= 50 ? ((schemeInt - 50) - ((schemeInt - 50) / 4) * 4)
                                   : schemeInt;
  float t = fract(basin + 0.55 * speed + uTime * 0.00006);
  vec3 col = palette(t, baseScheme);

  // Converged pixels stay bright; ones still wandering at the iteration limit
  // fade, which draws the basin boundaries.
  float settled = (it < target) ? 1.0 : 0.35;
  col *= 0.45 + 0.55 * settled;

  if (uTransparentBg > 0.5 && it >= target) {
    fragColor = vec4(0.0);
    return;
  }
  fragColor = vec4(linearToSRGB(col), 1.0);
}
