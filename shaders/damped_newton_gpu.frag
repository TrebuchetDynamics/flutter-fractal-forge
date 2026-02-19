#include <flutter/runtime_effect.glsl>

precision highp float;

// Damped Newton's Method Basins of Attraction.
// z_{n+1} = z_n - alpha * f(z_n) / f'(z_n)
// Polynomials: z^3-1, z^4-1, z^5-1 (selectable via uPolynomial).
// Damping factor alpha < 1 widens basins, alpha > 1 creates chaotic boundaries.
// Color by which root the iteration converges to, blended with convergence speed.
// Derivative (Julia-style dz/dz0):
//   g(z) = z - alpha*f(z)/f'(z)
//   derNew = g'(z) * der, der0 = (1,0)
// Supports normal-map shading (colorScheme 50-63).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uDamping;       // 10  alpha (default 1.0, range 0.1..2.0)
uniform float uPolynomial;    // 11  (0=z^3-1, 1=z^4-1, 2=z^5-1)

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear -> display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// colorScheme 0-49: standard palette. 50-63: normal-map (14 angles x 4 palettes).
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

// Compute z^n for integer n (3..5) via repeated multiplication.
vec2 cpow_int(vec2 z, int n) {
  vec2 result = vec2(1.0, 0.0);
  for (int i = 0; i < 8; i++) {
    if (i >= n) break;
    result = cmul(result, z);
  }
  return result;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  float alpha = clamp(uDamping, 0.1, 2.0);
  int poly = int(clamp(uPolynomial, 0.0, 2.0));
  int degree = 3 + poly; // 3, 4, or 5

  // Julia-style derivative for normal mapping
  vec2 der = vec2(1.0, 0.0);

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Compute z^(n-1) and z^n
    vec2 zn_1 = cpow_int(z, degree - 1);
    vec2 zn   = cmul(zn_1, z);

    // f(z) = z^n - 1
    vec2 fz = zn - vec2(1.0, 0.0);
    // f'(z) = n * z^(n-1)
    vec2 fpz = float(degree) * zn_1;

    vec2 step = cdiv(fz, fpz);

    // Derivative of damped Newton g(z) = z - alpha*f(z)/f'(z):
    // g'(z) = 1 - alpha*(1 - f(z)*f''(z)/(f'(z))^2)
    //       = (1 - alpha) + alpha * f(z)*f''(z)/(f'(z))^2
    // f''(z) = n*(n-1)*z^(n-2)
    vec2 zn_2 = (degree >= 3) ? cpow_int(z, degree - 2) : vec2(1.0, 0.0);
    vec2 fppz = float(degree) * float(degree - 1) * zn_2;
    vec2 fpz2 = cmul(fpz, fpz);
    vec2 ratio = cdiv(cmul(fz, fppz), fpz2);
    // g'(z) = 1 - alpha + alpha * ratio (complex)
    vec2 gp = vec2(1.0 - alpha, 0.0) + alpha * ratio;
    der = cmul(gp, der);

    z = z - alpha * step;

    if (dot(step, step) < 1e-12) { it = j; break; }
    if (dot(z, z) > max(uBailout * uBailout, 1024.0)) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Determine which root z converged to.
  // Roots of z^n - 1 are at exp(2*pi*i*k/n) for k = 0..n-1
  float bestDist = 1e10;
  float rootPhase = 0.0;
  for (int k = 0; k < 8; k++) {
    if (k >= degree) break;
    float angle = 6.28318 * float(k) / float(degree);
    vec2 root = vec2(cos(angle), sin(angle));
    float dist = dot(z - root, z - root);
    if (dist < bestDist) {
      bestDist = dist;
      rootPhase = float(k) / float(degree);
    }
  }

  // For root-finding, use iteration count + root phase for coloring
  float tBase = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime * 0.0001);

  // -- Normal-map shading (colorScheme 50-63) --
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    int basePal = (schemeInt - 50) % 4;
    fragColor = vec4(linearToSRGB(palette(tBase, basePal) * light), 1.0);
    return;
  }

  fragColor = vec4(linearToSRGB(palette(tBase, schemeInt)), 1.0);
}
