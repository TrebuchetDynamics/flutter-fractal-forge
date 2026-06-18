#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uPower;         // 10

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// colorScheme 0-49: standard palette coloring.
// colorScheme 50-63: normal-map (bas-relief) mode — 14 light angles × 4 base palettes.
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
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

vec2 cpowReal(vec2 z, float power) {
  float r = max(length(z), 1e-8);
  float a = atan(z.y, z.x);
  float rp = pow(r, power);
  return rp * vec2(cos(power * a), sin(power * a));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c   = uv / max(0.000001, uZoom) + uCenter;
  vec2 z   = vec2(0.0);
  float power = clamp(uPower, -8.0, 24.0);
  if (abs(power) < 0.001) power = 3.0;
  // Complex derivative dz/dc for normal-map shading.
  // d(z^p)/dc = p*z^(p-1) * der  →  der_next = p*z^(p-1)*der + 1
  vec2 der = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  // Early-out: for z0=0 in z -> z^d + c, first iterate is z1=c.
  // If |c| already exceeds bailout, we can skip the loop safely.
  if (dot(c, c) > bailoutSq) {
    z = c;
    der = vec2(1.0, 0.0);
    it = 0;
  } else {
    for (int j = 0; j < MAX_ITERS; j++) {
      if (j >= target) { it = target; break; }

      // z^p + c  (parameterized Multibrot)
      vec2 derivFactor = power * cpowReal(z, power - 1.0);
      der = cmul(derivFactor, der) + vec2(1.0, 0.0);
      z = cpowReal(z, power) + c;

      if (dot(z, z) > bailoutSq) { it = j; break; }
      it = j + 1;
    }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  // Continuous potential for z -> z^p + c (Douady/Hubbard smooth coloring):
  // nu = n + 1 - log(log|z_n|) / log(p).  Here |z| = sqrt(mag2).
  float logZn = 0.5 * log(mag2);
  float smoothVal = float(it) + 1.0 - log(max(1e-12, logZn)) / log(max(1.001, abs(power)));

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Normal estimate: nv = z / der  (complex division)
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;

    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    vec3 col = palette(baseT, basePal) * light;
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime*0.0001);
  vec3 color = palette(t, schemeInt);
  fragColor = vec4(linearToSRGB(color), 1.0);
}
