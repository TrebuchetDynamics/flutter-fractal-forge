#include <flutter/runtime_effect.glsl>

precision highp float;

// Laguerre's method on z^5 - 1 (n=5).
// G = f'/f,  H = G^2 - f''/f
// a = n / (G +/- sqrt((n-1)*(n*H - G^2)))
// z_new = z - a

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
  vec3 c_v = 1.0 + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c_v*t+d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b, b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}

vec2 csqrt(vec2 z) {
  float r = length(z);
  float a = atan(z.y, z.x) * 0.5;
  float sr = sqrt(r);
  return vec2(sr * cos(a), sr * sin(a));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  const int MAX_ITERS = 500;
  const float N = 5.0;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // z^2, z^3, z^4, z^5
    vec2 z2 = cmul(z, z);
    vec2 z3 = cmul(z2, z);
    vec2 z4 = cmul(z3, z);
    vec2 z5 = cmul(z4, z);

    vec2 fz  = z5 - vec2(1.0, 0.0);            // f(z) = z^5 - 1
    vec2 fpz = 5.0 * z4;                         // f'(z) = 5z^4
    vec2 fppz = 20.0 * z3;                       // f''(z) = 20z^3

    // G = f'/f,  H = G^2 - f''/f
    vec2 G = cdiv(fpz, fz);
    vec2 H = cmul(G, G) - cdiv(fppz, fz);

    // discriminant = (n-1)*(n*H - G^2)
    vec2 disc = (N - 1.0) * (N * H - cmul(G, G));
    vec2 sqrtDisc = csqrt(disc);

    // Choose sign to maximize denominator magnitude
    vec2 dPlus  = G + sqrtDisc;
    vec2 dMinus = G - sqrtDisc;
    vec2 denom = (dot(dPlus, dPlus) > dot(dMinus, dMinus)) ? dPlus : dMinus;

    vec2 step = cdiv(vec2(N, 0.0), denom);
    z = z - step;

    if (dot(step, step) < 1e-12) { it = j; break; }
    if (dot(z, z) > 64.0) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Roots of z^5 - 1: exp(2*pi*i*k/5) for k=0..4
  float bestDist = 1e10;
  float rootPhase = 0.0;
  for (int k = 0; k < 5; k++) {
    float angle = 6.28318 * float(k) / 5.0;
    vec2 root = vec2(cos(angle), sin(angle));
    float dist = dot(z - root, z - root);
    if (dist < bestDist) {
      bestDist = dist;
      rootPhase = float(k) / 5.0;
    }
  }

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime * 0.0001);
  vec3 color = palette(t, int(uColorScheme));
  fragColor = vec4(linearToSRGB(color), 1.0);
}
