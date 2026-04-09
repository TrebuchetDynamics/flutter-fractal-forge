#include <flutter/runtime_effect.glsl>

precision highp float;

// Durand-Kerner (Weierstrass) Simultaneous Root-Finder Dynamics.
// For polynomial p(z) = z^n - 1, we track one of the n simultaneous
// root approximations. Each pixel provides the initial guess for
// the tracked root r_k; other roots are initialized to regularly spaced values.
// Update rule: r_k = r_k - p(r_k) / product(r_k - r_j) for j != k
// Color by which actual root the approximation converges to, plus speed.
// Supports normal-map shading (colorScheme 50-63) via numerical central differences.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uDegree;        // 10  n (default 3, range 3..7)
uniform float uTrackRoot;     // 11  which root to track (default 0)

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

// Evaluate z^n for integer n via repeated multiplication.
vec2 cpow_int(vec2 z, int n) {
  vec2 result = vec2(1.0, 0.0);
  for (int i = 0; i < 8; i++) {
    if (i >= n) break;
    result = cmul(result, z);
  }
  return result;
}

// Run Durand-Kerner iteration from a given starting position for the tracked root.
// Returns vec3(iterCount, rootPhase, converged).
vec3 runDK(vec2 startPos, int n, int trackIdx, int target) {
  // Initialize root approximations
  vec2 roots[8];
  for (int k = 0; k < 8; k++) {
    if (k >= n) break;
    if (k == trackIdx) {
      roots[k] = startPos;
    } else {
      float ang = 6.28318 * float(k) / float(n);
      float rad = 1.0;
      for (int p = 0; p < 8; p++) {
        if (p >= k) break;
        rad *= 0.4;
      }
      roots[k] = vec2(rad * cos(ang), rad * sin(ang));
    }
  }

  const int MAX_ITERS = 500;
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 newRoots[8];
    for (int k = 0; k < 8; k++) {
      if (k >= n) break;
      vec2 pVal = cpow_int(roots[k], n) - vec2(1.0, 0.0);
      vec2 prod = vec2(1.0, 0.0);
      for (int m = 0; m < 8; m++) {
        if (m >= n) break;
        if (m == k) continue;
        vec2 diff = roots[k] - roots[m];
        if (dot(diff, diff) < 1e-20) diff = vec2(1e-10, 1e-10);
        prod = cmul(prod, diff);
      }
      newRoots[k] = roots[k] - cdiv(pVal, prod);
    }

    vec2 step = newRoots[trackIdx] - roots[trackIdx];
    for (int k = 0; k < 8; k++) {
      if (k >= n) break;
      roots[k] = newRoots[k];
    }

    if (dot(step, step) < 1e-12) { it = j; break; }
    if (dot(roots[trackIdx], roots[trackIdx]) > 1024.0) { it = j; break; }
    it = j + 1;
  }

  vec2 finalZ = roots[trackIdx];

  // Determine which actual root z^n=1 was found
  float bestDist = 1e10;
  float rootPhase = 0.0;
  for (int k = 0; k < 8; k++) {
    if (k >= n) break;
    float ang = 6.28318 * float(k) / float(n);
    vec2 actualRoot = vec2(cos(ang), sin(ang));
    float dist = dot(finalZ - actualRoot, finalZ - actualRoot);
    if (dist < bestDist) {
      bestDist = dist;
      rootPhase = float(k) / float(n);
    }
  }

  float converged = (it < target) ? 1.0 : 0.0;
  return vec3(float(it), rootPhase, converged);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 pixelPos = uv / max(0.000001, uZoom) + uCenter;

  int n = int(clamp(uDegree, 3.0, 7.0));
  int trackIdx = int(clamp(uTrackRoot, 0.0, float(n - 1)));
  int target = int(clamp(uIterations, 0.0, 500.0));

  // Main pixel computation
  vec3 result = runDK(pixelPos, n, trackIdx, target);
  int it = int(result.x);
  float rootPhase = result.y;
  float converged = result.z;

  if (converged < 0.5) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float tBase = fract(float(it) / max(1.0, uIterations) + rootPhase + uTime * 0.0001);

  // -- Normal-map shading (colorScheme 50-63) via numerical central differences --
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Numerical gradient: re-run DK at tiny offsets
    float eps = 1.0 / (max(0.000001, uZoom) * scale);
    vec3 rX = runDK(pixelPos + vec2(eps, 0.0), n, trackIdx, target);
    vec3 rY = runDK(pixelPos + vec2(0.0, eps), n, trackIdx, target);

    float hC = float(it) + rootPhase * max(1.0, uIterations);
    float hX = rX.x + rX.y * max(1.0, uIterations);
    float hY = rY.x + rY.y * max(1.0, uIterations);

    vec2 nv = vec2(hC - hX, hC - hY);
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen; else nv = vec2(0.0, 1.0);

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(tBase, basePal) * light), 1.0);
    return;
  }

  fragColor = vec4(linearToSRGB(palette(tBase, schemeInt)), 1.0);
}
