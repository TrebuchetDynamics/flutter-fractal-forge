#include <flutter/runtime_effect.glsl>

precision highp float;

// Gray-Scott Reaction-Diffusion — single-pass analytical approximation.
// Since we cannot do ping-pong multi-pass, we approximate RD textures using
// layered simplex noise at multiple scales, with F and k controlling the
// morphology (spots, stripes, labyrinth patterns).
// Extra params:
//   uFeedRate (float 10): F, default 0.04, range 0.01..0.08
//   uKillRate (float 11): k, default 0.06, range 0.04..0.08
//   uScale   (float 12): pattern scale, default 5.0, range 1..20
// Supports normal-map shading (colorScheme 50-63).

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uFeedRate;      // 10
uniform float uKillRate;      // 11
uniform float uScale;         // 12

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

// ---------- Simplex 2D noise ----------
// Permutation via hash
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289v2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289((x * 34.0 + 1.0) * x); }

float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187,   // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,   // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,   // -1.0 + 2.0 * C.x
                      0.024390243902439);  // 1.0 / 41.0

  // First corner
  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);

  // Other corners
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289v2(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));

  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;

  // Gradients from 41 points on a line, mapped onto a diamond
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

  // Compute final noise value at P
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.y = a0.y * x12.x + h.y * x12.y;
  g.z = a0.z * x12.z + h.z * x12.w;

  return 130.0 * dot(m, g);
}

// Fractal Brownian Motion using simplex noise
float fbm(vec2 p, int octaves) {
  float value = 0.0;
  float amp = 0.5;
  float freq = 1.0;

  for (int i = 0; i < 8; i++) {
    if (i >= octaves) break;
    value += amp * snoise(p * freq);
    freq *= 2.0;
    amp *= 0.5;
  }
  return value;
}

// Gray-Scott-like pattern approximation
// F and k control the morphology:
//   spots:     F ~ 0.035, k ~ 0.065
//   stripes:   F ~ 0.04,  k ~ 0.06
//   labyrinth: F ~ 0.06,  k ~ 0.062
float grayScottPattern(vec2 p, float F, float k, float time) {
  // Ratio of F to k determines pattern type
  float ratio = F / max(1e-6, k);

  // Base noise layers
  float n1 = snoise(p);
  float n2 = snoise(p * 2.03 + vec2(1.7, 9.2));
  float n3 = snoise(p * 4.01 + vec2(5.2, 1.3));

  // Domain warping for organic feel (slow animation)
  vec2 warp = vec2(
    snoise(p + vec2(time * 0.03, 0.0)),
    snoise(p + vec2(0.0, time * 0.03))
  );
  vec2 wp = p + warp * 0.3;

  // Morphology control:
  // Low ratio (spots): sharp positive peaks
  // Medium ratio (stripes): ridge patterns
  // High ratio (labyrinth): meandering ridges with domain warping

  float pattern;

  if (ratio < 0.55) {
    // SPOTS: Use noise peaks thresholded into dots
    float base = fbm(wp, 6);
    float spots = smoothstep(0.2, 0.5, base);
    // Add some secondary smaller spots
    float small = snoise(wp * 3.5 + vec2(time * 0.02));
    spots += 0.3 * smoothstep(0.3, 0.55, small);
    pattern = clamp(spots, 0.0, 1.0);
  } else if (ratio < 0.68) {
    // STRIPES: Use directional noise ridges
    float angle = n3 * 0.5;
    vec2 dir = vec2(cos(angle), sin(angle));
    float ridge = snoise(wp + dir * 0.5);
    float ridge2 = snoise(wp * 1.7 + vec2(time * 0.02));
    // Ridge function: take abs and invert to get stripe centers
    pattern = 1.0 - smoothstep(0.0, 0.35, abs(ridge + 0.1 * ridge2));
    // Mix in some domain-warped noise for irregularity
    float warpNoise = fbm(wp * 0.8 + warp * 0.5, 4);
    pattern = mix(pattern, smoothstep(-0.1, 0.3, warpNoise), 0.25);
  } else {
    // LABYRINTH: Heavy domain warping with ridge patterns
    vec2 warp2 = vec2(
      fbm(wp + vec2(1.3, 7.1) + vec2(time * 0.015), 5),
      fbm(wp + vec2(8.3, 2.8) + vec2(time * 0.015), 5)
    );
    vec2 lwp = wp + warp2 * 0.6;
    float ridge = snoise(lwp);
    float ridge2 = snoise(lwp * 1.5 + vec2(3.1, 5.7));
    pattern = 1.0 - smoothstep(0.0, 0.3, abs(ridge + 0.15 * ridge2));
    // More organic edges
    float edge = fbm(lwp * 2.0, 3);
    pattern *= smoothstep(-0.4, 0.1, edge);
  }

  // Animate: subtle temporal modulation
  pattern *= 0.85 + 0.15 * sin(time * 0.1 + n1 * 3.0);

  return clamp(pattern, 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  float F = clamp(uFeedRate, 0.01, 0.08);
  float k = clamp(uKillRate, 0.04, 0.08);
  float patternScale = clamp(uScale, 1.0, 20.0);
  int schemeInt = int(uColorScheme);
  float time = uTime * 0.01;

  // Scale the coordinate
  vec2 sp = p * patternScale;

  float pattern = grayScottPattern(sp, F, k, time);

  // Normal-map shading (colorScheme 50-63)
  if (schemeInt >= 50) {
    float eps = 0.01 / max(0.000001, uZoom);
    float pR = grayScottPattern((p + vec2(eps, 0.0)) * patternScale, F, k, time);
    float pU = grayScottPattern((p + vec2(0.0, eps)) * patternScale, F, k, time);

    vec2 grad = vec2(pR - pattern, pU - pattern) / eps;
    float gLen = length(grad);
    vec2 nv = (gLen > 1e-6) ? grad / gLen : vec2(0.0);

    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(pattern + uTime * 0.00005);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  if (pattern < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Color: chemical U is background (low pattern), chemical V is the pattern
  float t = fract(pattern * 0.8 + 0.1 + uTime * 0.00005);
  vec3 col = palette(t, schemeInt);

  // Modulate: pattern regions brighter, background darker
  vec3 bgColor = palette(0.1, schemeInt) * 0.15;
  col = mix(bgColor, col, smoothstep(0.05, 0.4, pattern));

  float alpha = (uTransparentBg > 0.5) ? smoothstep(0.0, 0.05, pattern) : 1.0;
  fragColor = vec4(linearToSRGB(col), alpha);
}
