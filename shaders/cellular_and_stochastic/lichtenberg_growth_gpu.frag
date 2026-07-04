#include <flutter/runtime_effect.glsl>

precision highp float;

// Lichtenberg Growth — radial growth variant of Dielectric Breakdown Model.
// Growth front expands from center outward over time (uTime controls growth radius).
// Uses domain-warped noise for organic branching with thin anti-aliased lines.
// Extra params:
//   uGrowthSpeed (float 10): default 0.3, range 0.1..1.0
//   uBranchAngle (float 11): default 0.5, range 0.1..1.5
//   uComplexity  (float 12): noise octaves, default 5, range 3..8
// Supports normal-map shading (colorScheme 50-63).

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uGrowthSpeed;   // 10
uniform float uBranchAngle;   // 11
uniform float uComplexity;    // 12

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
float hash21(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float hash11(float p) {
  p = fract(p * 0.1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

// Smooth value noise
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

// fBm with variable octaves
float fbm(vec2 p, int octaves) {
  float val = 0.0;
  float amp = 0.5;
  float freq = 1.0;
  for (int i = 0; i < 8; i++) {
    if (i >= octaves) break;
    val += amp * vnoise(p * freq);
    freq *= 2.03;
    amp *= 0.49;
  }
  return val;
}

// Domain-warped fBm for organic patterns
float warpedFbm(vec2 p, int octaves, float warpAmt) {
  vec2 q = vec2(
    fbm(p + vec2(0.0, 0.0), octaves),
    fbm(p + vec2(5.2, 1.3), octaves)
  );
  vec2 r = vec2(
    fbm(p + warpAmt * q + vec2(1.7, 9.2), octaves),
    fbm(p + warpAmt * q + vec2(8.3, 2.8), octaves)
  );
  return fbm(p + warpAmt * r, octaves);
}

// Distance to segment
float sdSegment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h);
}

float lichtenbergGrowthRadius(float growthSpeed, float time, int iters) {
  float staticRadius = mix(0.22, 1.05, clamp(float(iters) / 50.0, 0.0, 1.0));
  return min(1.25, staticRadius * (0.65 + 0.35 * growthSpeed) + time * growthSpeed * 0.04);
}

// Lichtenberg growth field computation
// Returns vec3(distance, generation, radialDist)
vec3 lichtenbergField(vec2 p, float growthSpeed, float branchAngle, int complexity, float time, int iters) {
  float minDist = 1e6;
  float bestGen = 0.0;
  float bestRadial = 0.0;

  // Growth front radius. Include iteration-driven visible growth so static
  // share previews don't open on a blank seed frame.
  float growthRadius = lichtenbergGrowthRadius(growthSpeed, time, iters);

  // Number of primary arms
  int numArms = 5 + int(float(complexity) * 0.5);

  for (int arm = 0; arm < 10; arm++) {
    if (arm >= numArms) break;

    float fa = float(arm);
    float baseAngle = 6.28318 * fa / float(numArms);

    // Trace the arm from center outward
    vec2 pos = vec2(0.0);
    float angle = baseAngle;
    float segLen = 0.04;
    float radialDist = 0.0;

    for (int seg = 0; seg < 50; seg++) {
      if (seg >= iters) break;

      float fs = float(seg);
      radialDist += segLen;

      // Stop at growth front
      if (radialDist > growthRadius) break;

      // Domain-warped angle perturbation
      vec2 noisePos = vec2(fa * 5.0 + fs * 0.7, fs * 1.3);
      float anglePerturbation = (vnoise(noisePos * 3.0) - 0.5) * branchAngle * 2.0;

      // Noise-driven curvature
      float curvature = (fbm(noisePos + vec2(fa * 2.3), complexity) - 0.5) * branchAngle;
      angle += anglePerturbation * 0.3 + curvature * 0.5;

      vec2 nextPos = pos + segLen * vec2(cos(angle), sin(angle));

      float d = sdSegment(p, pos, nextPos);
      if (d < minDist) {
        minDist = d;
        bestGen = 0.0;
        bestRadial = radialDist;
      }

      // Secondary branching
      float branchProb = 0.4 * (1.0 - radialDist / max(0.01, growthRadius));
      float bHash = hash21(vec2(fa * 7.3, fs * 3.1));

      if (bHash < branchProb) {
        float subAngle = angle + (hash11(fa + fs * 11.0) - 0.5) * branchAngle * 3.0;
        vec2 subPos = mix(pos, nextPos, hash11(fa * 3.0 + fs));
        float subLen = segLen * 0.7;
        float subRadial = radialDist;

        for (int ss = 0; ss < 25; ss++) {
          float fss = float(ss);
          subRadial += subLen;
          if (subRadial > growthRadius) break;

          float subNoise = (vnoise(vec2(fa * 11.0 + fss * 1.1, fs * 2.0 + fss) * 2.5) - 0.5);
          subAngle += subNoise * branchAngle * 1.5;

          vec2 subNext = subPos + subLen * vec2(cos(subAngle), sin(subAngle));

          float sd = sdSegment(p, subPos, subNext);
          if (sd < minDist) {
            minDist = sd;
            bestGen = 1.0;
            bestRadial = subRadial;
          }

          // Tertiary branching
          float tHash = hash21(vec2(fa * 13.0 + fss * 5.7, fs * 7.0));
          if (tHash < branchProb * 0.3) {
            float tAngle = subAngle + (hash11(fa + fss * 17.0 + fs) - 0.5) * branchAngle * 4.0;
            vec2 tPos = subNext;
            float tLen = subLen * 0.55;
            float tRadial = subRadial;

            for (int ts = 0; ts < 12; ts++) {
              float fts = float(ts);
              tRadial += tLen;
              if (tRadial > growthRadius) break;

              float tNoise = (vnoise(vec2(fa * 17.0 + fts, fss * 3.0 + ts) * 3.0) - 0.5);
              tAngle += tNoise * branchAngle * 2.0;

              vec2 tNext = tPos + tLen * vec2(cos(tAngle), sin(tAngle));
              float td = sdSegment(p, tPos, tNext);
              if (td < minDist) {
                minDist = td;
                bestGen = 2.0;
                bestRadial = tRadial;
              }
              tPos = tNext;
              tLen *= 0.88;
            }
          }

          subPos = subNext;
          subLen *= 0.9;
        }
      }

      pos = nextPos;
      segLen *= 0.95;
    }
  }

  return vec3(minDist, bestGen, bestRadial);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  float growthSpeed = clamp(uGrowthSpeed, 0.1, 1.0);
  float branchAngle = clamp(uBranchAngle, 0.1, 1.5);
  int complexity = int(clamp(uComplexity, 3.0, 8.0));
  int iters = int(clamp(uIterations, 1.0, 50.0));
  int schemeInt = int(uColorScheme);
  float time = uTime;

  // Growth radius for growth-front visualization
  float growthRadius = lichtenbergGrowthRadius(growthSpeed, time, iters);

  vec3 field = lichtenbergField(p, growthSpeed, branchAngle, complexity, time, iters);
  float dist = field.x;
  float gen = field.y;
  float radialDist = field.z;

  // Branch thickness: thinner for higher generations, anti-aliased
  float baseThick = 0.006;
  float thickness = baseThick * exp(-gen * 0.6);

  // Anti-aliased lines via smoothstep
  float line = smoothstep(thickness * 2.0, thickness * 0.3, dist);
  float glow = smoothstep(thickness * 10.0, thickness, dist) * 0.4;

  // Growth front glow
  float rFromCenter = length(p);
  float frontDist = abs(rFromCenter - growthRadius);
  float frontGlow = smoothstep(0.03, 0.0, frontDist) * 0.3 * step(0.01, growthRadius);

  float intensity = line + glow + frontGlow;

  // Normal-map shading (colorScheme 50-63)
  if (schemeInt >= 50) {
    float eps = 0.003 / max(0.000001, uZoom);
    vec3 fR = lichtenbergField(p + vec2(eps, 0.0), growthSpeed, branchAngle, complexity, time, iters);
    vec3 fU = lichtenbergField(p + vec2(0.0, eps), growthSpeed, branchAngle, complexity, time, iters);

    float iR = smoothstep(thickness * 2.0, thickness * 0.3, fR.x) +
               smoothstep(thickness * 10.0, thickness, fR.x) * 0.4;
    float iU = smoothstep(thickness * 2.0, thickness * 0.3, fU.x) +
               smoothstep(thickness * 10.0, thickness, fU.x) * 0.4;

    vec2 grad = vec2(iR - (line + glow), iU - (line + glow)) / eps;
    float gLen = length(grad);
    vec2 nv = (gLen > 1e-6) ? grad / gLen : vec2(0.0);

    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(gen * 0.25 + radialDist * 2.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    vec3 col = palette(baseT, basePal) * light * max(intensity, 0.1);
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  if (intensity < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Color by generation depth + radial distance from growth front
  float distFromFront = max(0.0, growthRadius - radialDist);
  float t = fract(gen * 0.2 + distFromFront * 3.0 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);

  // Bright tips near growth front, dimmer at core
  float tipBrightness = smoothstep(0.0, 0.05, distFromFront);
  tipBrightness = 1.0 - tipBrightness * 0.4;

  // Core of branches is bright white
  vec3 coreCol = mix(vec3(1.0, 1.0, 0.95), col, 0.5);
  vec3 finalCol = mix(col * glow, coreCol * line, line / max(0.001, line + glow));
  finalCol *= tipBrightness;
  finalCol += col * frontGlow;
  finalCol = clamp(finalCol, 0.0, 1.0);

  float alpha = (uTransparentBg > 0.5) ? smoothstep(0.0, 0.015, intensity) : 1.0;
  fragColor = vec4(linearToSRGB(finalCol), alpha);
}
