#include <flutter/runtime_effect.glsl>

precision highp float;

// Dielectric Breakdown Model / Lichtenberg Figure — single-pass approximation.
// Uses fractal Brownian motion noise with directional bias to create
// lightning-tree branching patterns radiating from the center.
// Distance field from procedural branches for smooth rendering.
// Extra params:
//   uBranchDensity (float 10): default 0.5, range 0.1..1.0
//   uEta           (float 11): field exponent, default 1.0, range 0.5..3.0
//   uSeed          (float 12): random seed for pattern variation, default 0.0, range 0..10
// Supports normal-map shading (colorScheme 50-63).

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uBranchDensity; // 10
uniform float uEta;           // 11
uniform float uSeed;          // 12

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear -> display-encoded).
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
  vec3 c_v = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c_v * t + d)), 0.0, 1.0);
}

// ---------- noise utilities ----------
float hash11(float p) {
  p = fract(p * 0.1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

float hash21(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy);
}

// Value noise
float vnoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);

  float a = hash21(i);
  float b = hash21(i + vec2(1.0, 0.0));
  float c = hash21(i + vec2(0.0, 1.0));
  float d = hash21(i + vec2(1.0, 1.0));

  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// fBm with configurable octaves
float fbm(vec2 p, int octaves) {
  float value = 0.0;
  float amp = 0.5;
  float freq = 1.0;
  for (int i = 0; i < 8; i++) {
    if (i >= octaves) break;
    value += amp * (vnoise(p * freq) * 2.0 - 1.0);
    freq *= 2.17;
    amp *= 0.48;
  }
  return value;
}

// Distance to a line segment
float sdSegment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h);
}

// Compute the lightning/breakdown pattern as a distance field
// Returns (distance, generation depth)
vec2 lightningField(vec2 p, float density, float eta, float seed, float time, int iters) {
  float minDist = 1e6;
  float bestGen = 0.0;

  // Number of primary branches
  int numBranches = int(3.0 + density * 9.0); // 3 to 12

  // Growth radius animated by time
  float maxRadius = 0.5 + time * 0.03;

  for (int branch = 0; branch < 12; branch++) {
    if (branch >= numBranches) break;

    float fb = float(branch);
    // Base angle for this primary branch
    float baseAngle = 6.28318 * (fb / float(numBranches)) + seed * 1.7;
    baseAngle += fbm(vec2(fb + seed, 0.0), 3) * 0.8;

    // Trace main branch as segments
    vec2 pos = vec2(0.0); // Start from center
    float angle = baseAngle;
    float segLen = 0.08 + 0.04 * hash11(fb + seed);
    float gen = 0.0;

    for (int seg = 0; seg < 40; seg++) {
      if (seg >= iters) break;

      float fs = float(seg);
      // Perturb angle with noise (eta controls jaggedness)
      float noiseBias = fbm(vec2(fb * 3.1 + seed, fs * 1.7), 4);
      angle += noiseBias * 0.7 * pow(eta, 0.5);

      // Next segment endpoint
      vec2 nextPos = pos + segLen * vec2(cos(angle), sin(angle));

      // Check distance from point to this segment
      float d = sdSegment(p, pos, nextPos);
      if (d < minDist) {
        minDist = d;
        bestGen = gen;
      }

      // Branching: spawn sub-branches at some segments
      float branchProb = density * 0.5 * pow(0.85, gen);
      float branchHash = hash21(vec2(fb * 7.3 + fs * 1.1, seed + 3.14));

      if (branchHash < branchProb && gen < 3.0) {
        // Sub-branch
        float subAngle = angle + (hash11(fb + fs * 2.3 + seed) - 0.5) * 2.0;
        vec2 subPos = nextPos;
        float subLen = segLen * 0.6;

        for (int ss = 0; ss < 15; ss++) {
          float fss = float(ss);
          float subNoise = fbm(vec2(fb * 5.0 + fs * 2.0 + fss * 1.3, seed * 2.0), 3);
          subAngle += subNoise * 0.9 * pow(eta, 0.5);

          vec2 subNext = subPos + subLen * vec2(cos(subAngle), sin(subAngle));
          float sd = sdSegment(p, subPos, subNext);
          if (sd < minDist) {
            minDist = sd;
            bestGen = gen + 1.0;
          }

          // Tertiary branching
          float tertiaryHash = hash21(vec2(fb * 11.0 + fss * 3.7, seed + fs));
          if (tertiaryHash < branchProb * 0.4 && gen < 2.0) {
            float tAngle = subAngle + (hash11(fb + fss * 5.1 + seed * 3.0) - 0.5) * 2.5;
            vec2 tPos = subNext;
            float tLen = subLen * 0.5;
            for (int ts = 0; ts < 8; ts++) {
              float fts = float(ts);
              tAngle += fbm(vec2(fb + fss + fts, seed * 3.0), 2) * 1.0 * pow(eta, 0.5);
              vec2 tNext = tPos + tLen * vec2(cos(tAngle), sin(tAngle));
              float td = sdSegment(p, tPos, tNext);
              if (td < minDist) {
                minDist = td;
                bestGen = gen + 2.0;
              }
              tPos = tNext;
              tLen *= 0.85;
            }
          }

          subPos = subNext;
          subLen *= 0.88;
        }
      }

      pos = nextPos;
      segLen *= 0.92;
      gen = min(gen + 0.1, 3.0);
    }
  }

  return vec2(minDist, bestGen);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  float density = clamp(uBranchDensity, 0.1, 1.0);
  float eta = clamp(uEta, 0.5, 3.0);
  float seed = uSeed;
  int iters = int(clamp(uIterations, 1.0, 40.0));
  int schemeInt = int(uColorScheme);
  float time = uTime;

  vec2 field = lightningField(p, density, eta, seed, time, iters);
  float dist = field.x;
  float gen = field.y;

  // Branch thickness decreases with generation
  float thickness = 0.008 + 0.006 * exp(-gen * 0.5);
  float glow = smoothstep(thickness * 8.0, thickness * 0.5, dist);
  float core = smoothstep(thickness * 1.5, thickness * 0.2, dist);

  // Electric field glow using eta
  float fieldGlow = pow(max(0.0, 1.0 - dist * 3.0), eta) * 0.3;

  float intensity = core + glow * 0.6 + fieldGlow;

  // Normal-map shading (colorScheme 50-63)
  if (schemeInt >= 50) {
    float eps = 0.003 / max(0.000001, uZoom);
    vec2 fR = lightningField(p + vec2(eps, 0.0), density, eta, seed, time, iters);
    vec2 fU = lightningField(p + vec2(0.0, eps), density, eta, seed, time, iters);

    float iR = smoothstep(thickness * 1.5, thickness * 0.2, fR.x) +
               smoothstep(thickness * 8.0, thickness * 0.5, fR.x) * 0.6;
    float iU = smoothstep(thickness * 1.5, thickness * 0.2, fU.x) +
               smoothstep(thickness * 8.0, thickness * 0.5, fU.x) * 0.6;

    vec2 grad = vec2(iR - intensity, iU - intensity) / eps;
    float gLen = length(grad);
    vec2 nv = (gLen > 1e-6) ? grad / gLen : vec2(0.0);

    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(gen * 0.2 + dist * 5.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    vec3 col = palette(baseT, basePal) * light * max(intensity, 0.15);
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  if (intensity < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Color: core is bright white/blue, outer glow colored by palette
  float t = fract(gen * 0.15 + dist * 3.0 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);

  // Lightning aesthetic: bright core, colored glow
  vec3 coreColor = mix(vec3(0.9, 0.95, 1.0), col * 1.5, 0.3);
  vec3 glowColor = col * 0.8;

  vec3 finalCol = coreColor * core + glowColor * glow * 0.7 + col * fieldGlow;
  finalCol = clamp(finalCol, 0.0, 1.0);

  float alpha = (uTransparentBg > 0.5) ? smoothstep(0.0, 0.02, intensity) : 1.0;
  fragColor = vec4(linearToSRGB(finalCol), alpha);
}
