#include <flutter/runtime_effect.glsl>

precision highp float;

// Superexponential Fractal: z_{n+1} = c^z (iterate from z=0)
// Convergent-style: colors by convergence vs divergence.
// Points that converge are colored by final orbit distance;
// points that diverge are colored by escape iteration.
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
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  } else if (scheme == 1) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  } else if (scheme == 2) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c4 = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c4 * t + d)), 0.0, 1.0);
}

vec2 cx_mul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
vec2 cx_exp(vec2 z) { float e = exp(z.x); return vec2(e*cos(z.y), e*sin(z.y)); }
// c^z = exp(z * ln(c))
// ln(c) = ln|c| + i*arg(c)
vec2 cx_log(vec2 z) { return vec2(0.5 * log(max(1e-20, dot(z,z))), atan(z.y, z.x)); }
vec2 cx_pow(vec2 base, vec2 exponent) { return cx_exp(cx_mul(exponent, cx_log(base))); }

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  vec2 z = vec2(0.0);
  vec2 zPrev = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  bool escaped = false;
  bool converged = false;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    zPrev = z;
    // z = c^z
    if (dot(c, c) < 1e-20) {
      z = vec2(0.0);
    } else {
      z = cx_pow(c, z);
    }
    // Clamp to prevent inf/nan
    z.x = clamp(z.x, -1e6, 1e6);
    z.y = clamp(z.y, -1e6, 1e6);
    if (dot(z, z) > bailoutSq) { it = j; escaped = true; break; }
    // Convergence check
    vec2 diff = z - zPrev;
    if (dot(diff, diff) < 1e-12) { it = j; converged = true; break; }
    it = j + 1;
  }

  // Convergent coloring
  if (converged) {
    float dist = length(z);
    float t = fract(dist * 2.0 + atan(z.y, z.x) / 6.28318 + uTime * 0.0001);
    vec3 col = palette(t, schemeInt < 50 ? schemeInt : (schemeInt - 50) % 4);
    fragColor = vec4(linearToSRGB(col * 0.8), 1.0);
    return;
  }

  if (!escaped) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(max(1.0, log2(mag2))) + 4.0;

  if (schemeInt >= 50) {
    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    vec2 nv = normalize(z);
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);
    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) % 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
