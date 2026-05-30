#include <flutter/runtime_effect.glsl>

precision highp float;

// Golden-Ratio Mandelbrot ("Damaged DoubleBrot") — from MandlebrotSetSFML formula #13.
// Iteration: z_{n+1} = |z_n|^φ * exp(i·φ·arg(z_n)) + c    where φ = (1+√5)/2 ≈ 1.618
// Replacing z^2 with z^φ destroys all rotational symmetry (φ is irrational),
// producing aperiodic fractal geometry unlike any rational-power set.
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
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c*t+d)), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = vec2(0.0);

  // φ = golden ratio = (1 + √5) / 2
  const float PHI = 1.6180339887498948482;

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  int schemeInt = int(uColorScheme);
  vec2 der = vec2(0.0);

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Polar form: z_{n+1} = |z|^φ * (cos(φ·θ) + i·sin(φ·θ)) + c
    // d/dc: φ·|z|^(φ-1)·e^(i(φ-1)θ)·der + 1
    float mag = length(z);
    if (mag < 1e-10) {
      der = vec2(1.0, 0.0);
      z = c;
    } else {
      float theta     = atan(z.y, z.x);
      float derScale  = PHI * pow(mag, PHI - 1.0);
      float derAngle  = (PHI - 1.0) * theta;
      float dfx = derScale * cos(derAngle);
      float dfy = derScale * sin(derAngle);
      der = vec2(dfx * der.x - dfy * der.y + 1.0,
                 dfx * der.y + dfy * der.x);
      float magPow   = pow(mag, PHI);
      float newAngle = PHI * theta;
      z = vec2(magPow * cos(newAngle), magPow * sin(newAngle)) + c;
    }

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  // Smooth coloring: mu = n - log(log|z|) / log(φ)
  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log(0.5 * log(mag2)) / log(PHI);

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float lightAngle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir    = vec2(cos(lightAngle), sin(lightAngle));

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
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
