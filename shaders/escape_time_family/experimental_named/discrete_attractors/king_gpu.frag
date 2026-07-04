#include <flutter/runtime_effect.glsl>

precision highp float;

// King's method on z^3 - 1 with parameter beta.
// y = z - f(z)/f'(z)
// z_new = y - f(y)/f'(z) * (f(y) + beta*f(z)) / (f(y) + (beta-2)*f(z))

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uBeta;          // 10 (default 0.5)

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

vec2 f_z3m1(vec2 z) {
  vec2 z2 = cmul(z, z);
  return cmul(z2, z) - vec2(1.0, 0.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;
  float beta = uBeta;

  // ponytail: King's method converges fast; 500 root iterations only hurts catalog render time.
  const int MAX_ITERS = 80;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 z2 = cmul(z, z);
    vec2 fz = cmul(z2, z) - vec2(1.0, 0.0);
    vec2 fpz = 3.0 * z2;

    // Newton step: y = z - f(z)/f'(z)
    vec2 y = z - cdiv(fz, fpz);
    vec2 fy = f_z3m1(y);

    // King correction
    vec2 num = fy + beta * fz;
    vec2 den = fy + (beta - 2.0) * fz;
    vec2 ratio = cdiv(fy, fpz);
    vec2 kingCorr = cdiv(num, den);

    vec2 zNew = y - cmul(ratio, kingCorr);
    vec2 totalStep = z - zNew;
    z = zNew;

    if (dot(totalStep, totalStep) < 1e-12) { it = j; break; }
    if (dot(z, z) > 64.0) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec2 r0 = vec2(1.0, 0.0);
  vec2 r1 = vec2(-0.5, 0.86602540378);
  vec2 r2 = vec2(-0.5, -0.86602540378);

  float d0 = dot(z - r0, z - r0);
  float d1 = dot(z - r1, z - r1);
  float d2 = dot(z - r2, z - r2);

  float rootPhase = 0.0;
  if (d1 < d0 && d1 < d2) rootPhase = 0.3333333;
  else if (d2 < d0 && d2 < d1) rootPhase = 0.6666667;

  float t = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime * 0.0001);
  vec3 color = palette(t, int(uColorScheme));
  fragColor = vec4(linearToSRGB(color), 1.0);
}
