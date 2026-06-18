#include <flutter/runtime_effect.glsl>

precision highp float;

// Fractal Flame — single-pass IFS with nonlinear variations.
// For each pixel, run forward IFS iterations from the pixel's world position,
// accumulating color based on which affine transforms + variations are applied.
// Extra params:
//   uVariation (float 10): 0=linear, 1=sinusoidal, 2=spherical, 3=swirl, 4=horseshoe
//   uSymmetry  (float 11): 0=none, 1=bilateral, 2=3-fold, 3=6-fold
// Supports normal-map shading (colorScheme 50-63).

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uVariation;     // 10
uniform float uSymmetry;      // 11

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

// ---------- pseudo-random hash utilities ----------
float hash21(vec2 p) {
  p = fract(p * vec2(443.8975, 397.2973));
  p += dot(p, p + 19.19);
  return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
  return vec2(hash21(p), hash21(p + vec2(37.0, 17.0)));
}

// ---------- nonlinear variation functions ----------
vec2 varLinear(vec2 p) {
  return p;
}

vec2 varSinusoidal(vec2 p) {
  return sin(p);
}

vec2 varSpherical(vec2 p) {
  float r2 = dot(p, p) + 1e-6;
  return p / r2;
}

vec2 varSwirl(vec2 p) {
  float r2 = dot(p, p);
  float sr = sin(r2);
  float cr = cos(r2);
  return vec2(p.x * sr - p.y * cr, p.x * cr + p.y * sr);
}

vec2 varHorseshoe(vec2 p) {
  float r = length(p) + 1e-6;
  return (1.0 / r) * vec2((p.x - p.y) * (p.x + p.y), 2.0 * p.x * p.y);
}

vec2 cdiv(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-6);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

vec2 applyVariation(vec2 p, int var_id) {
  float r = max(length(p), 1e-6);
  float r2 = max(dot(p, p), 1e-6);
  float theta = atan(p.y, p.x);
  float phi = atan(p.x, p.y);

  if (var_id == 0) return varLinear(p);
  if (var_id == 1) return varSinusoidal(p);
  if (var_id == 2) return varSpherical(p);
  if (var_id == 3) return varSwirl(p);
  if (var_id == 4) return varHorseshoe(p);
  if (var_id == 5) return vec2(theta / 3.14159265, r - 1.0); // polar
  if (var_id == 6) return r * vec2(sin(theta + r), cos(theta - r)); // handkerchief
  if (var_id == 7) return r * vec2(sin(theta * r), -cos(theta * r)); // heart
  if (var_id == 8) return (theta / 3.14159265) * vec2(sin(3.14159265 * r), cos(3.14159265 * r)); // disc
  if (var_id == 9) return (1.0 / r) * vec2(cos(theta) + sin(r), sin(theta) - cos(r)); // spiral
  if (var_id == 10) return vec2(sin(theta) / r, r * cos(theta)); // hyperbolic
  if (var_id == 11) return sin(theta) * cos(theta) * vec2(1.0, 1.0); // diamond
  if (var_id == 12) {
    float p0 = sin(theta + r);
    float p1 = cos(theta - r);
    return r * vec2(p0 * p0 * p0 + p1 * p1 * p1, p0 * p0 * p0 - p1 * p1 * p1);
  }
  if (var_id == 13) {
    float omega = (p.x >= 0.0) ? 0.0 : 3.14159265;
    return sqrt(r) * vec2(cos(theta * 0.5 + omega), sin(theta * 0.5 + omega));
  }
  if (var_id == 14) return vec2(p.x >= 0.0 ? p.x : 2.0 * p.x, p.y >= 0.0 ? p.y : 0.5 * p.y); // bent
  if (var_id == 15) return vec2(p.x + 0.35 * sin(p.y / 0.55), p.y + 0.55 * sin(p.x / 0.35)); // waves
  if (var_id == 16) return (2.0 / (r + 1.0)) * p; // fisheye
  if (var_id == 17) return vec2(p.x + 0.05 * sin(tan(3.0 * p.y)), p.y + 0.05 * sin(tan(3.0 * p.x))); // popcorn
  if (var_id == 18) return exp(p.x - 1.0) * vec2(cos(3.14159265 * p.y), sin(3.14159265 * p.y)); // exponential
  if (var_id == 19) return pow(r, sin(theta)) * vec2(cos(theta), sin(theta)); // power
  if (var_id == 20) return vec2(cos(3.14159265 * p.x) * cosh(p.y), -sin(3.14159265 * p.x) * sinh(p.y)); // cosine
  if (var_id == 21) return mod(r + 0.35, 0.7) - 0.35 + r * vec2(cos(theta), sin(theta)); // rings
  if (var_id == 22) {
    float f = 3.14159265 * mod(theta + 0.5, 1.0);
    return r * vec2(cos(theta + f), sin(theta + f));
  }
  if (var_id == 23) return p * (0.65 + 0.35 * sin(5.0 * theta)); // blob
  if (var_id == 24) return vec2(sin(2.3 * p.y) - cos(1.9 * p.x), sin(2.1 * p.x) - cos(2.7 * p.y)); // PDJ
  if (var_id == 25) return r * vec2(sin(theta + sin(3.0 * theta)), cos(theta - sin(3.0 * theta))); // fan2
  if (var_id == 26) return p * (0.75 + 0.25 * cos(8.0 * r)); // rings2
  if (var_id == 27) return (2.0 / (r + 1.0)) * vec2(p.y, p.x); // eyefish
  if (var_id == 28) return (4.0 / (r2 + 4.0)) * p; // bubble
  if (var_id == 29) return vec2(sin(p.x), p.y); // cylinder
  if (var_id == 30) return p / max(1.0 - 0.35 * p.y, 0.2); // perspective
  if (var_id == 31) return p + 0.08 * vec2(sin(91.7 * dot(p, vec2(12.1, 3.7))), sin(77.3 * dot(p, vec2(4.3, 19.1)))); // noise
  if (var_id == 32) {
    float n = 3.0;
    return pow(r, 1.0 / n) * vec2(cos(theta / n), sin(theta / n));
  }
  if (var_id == 33) {
    float n = 3.0;
    float omega = floor(mod(abs(theta) * n / 6.2831853, n));
    return pow(r, 1.0 / n) * vec2(cos((theta + 2.0 * 3.14159265 * omega) / n), sin((theta + 2.0 * 3.14159265 * omega) / n));
  }
  if (var_id == 34) return vec2(0.5 * p.x, p.y); // blur proxy, deterministic
  if (var_id == 35) return p + 0.12 * vec2(sin(37.0 * p.x), cos(41.0 * p.y)); // gaussian blur proxy
  if (var_id == 36) return p + 0.16 * vec2(cos(theta), sin(theta)); // radial blur proxy
  if (var_id == 37) return 0.5 * vec2(cos(theta), sin(theta)) + vec2(0.15 * sin(5.0 * theta), 0.15 * cos(5.0 * theta)); // pie
  if (var_id == 38) {
    float sides = 5.0;
    float sector = 6.2831853 / sides;
    float a = mod(theta + 0.5 * sector, sector) - 0.5 * sector;
    return r * vec2(cos(a), sin(a));
  }
  if (var_id == 39) return cdiv(p, vec2(1.0, 0.45 * r2)); // curl
  if (var_id == 40) return vec2((floor(p.x * 3.0) + 0.5) / 3.0, (floor(p.y * 3.0) + 0.5) / 3.0); // rectangles
  return varLinear(p);
}

// ---------- affine transforms (3 IFS functions) ----------
vec2 affine0(vec2 p, float t) {
  float a = 0.6 + 0.1 * sin(t * 0.3);
  return vec2(a * p.x - 0.4 * p.y + 0.2,
              0.4 * p.x + a * p.y - 0.1);
}

vec2 affine1(vec2 p, float t) {
  float a = -0.5 + 0.1 * cos(t * 0.2);
  return vec2(a * p.x + 0.3 * p.y + 0.5,
              -0.3 * p.x + 0.5 * p.y + 0.3);
}

vec2 affine2(vec2 p, float t) {
  return vec2(0.35 * p.x - 0.35 * p.y - 0.2,
              0.35 * p.x + 0.35 * p.y + 0.4 + 0.05 * sin(t * 0.15));
}

// Apply symmetry fold
vec2 applySymmetry(vec2 p, int sym) {
  if (sym == 1) {
    // bilateral: fold across y-axis
    return vec2(abs(p.x), p.y);
  } else if (sym == 2) {
    // 3-fold: rotate to principal sector
    float angle = atan(p.y, p.x);
    float sector = 6.28318 / 3.0;
    angle = mod(angle + sector * 0.5, sector) - sector * 0.5;
    float r = length(p);
    return r * vec2(cos(angle), sin(angle));
  } else if (sym == 3) {
    // 6-fold
    float angle = atan(p.y, p.x);
    float sector = 6.28318 / 6.0;
    angle = mod(angle + sector * 0.5, sector) - sector * 0.5;
    float r = length(p);
    return r * vec2(cos(angle), sin(angle));
  }
  return p;
}

// Run IFS orbit density for a given world point
float flameDensity(vec2 p, int target, int var_id, int sym, float time) {
  p = applySymmetry(p, sym);

  float density = 0.0;
  vec2 z = p;

  for (int i = 0; i < 200; i++) {
    if (i >= target) break;

    // Select transform based on hash of iteration + position
    float h = hash21(vec2(float(i) * 1.31, float(i) * 0.97 + z.x * 0.1));
    vec2 zt;
    float colorWeight;

    if (h < 0.4) {
      zt = affine0(z, time);
      colorWeight = 0.0;
    } else if (h < 0.7) {
      zt = affine1(z, time);
      colorWeight = 0.33;
    } else {
      zt = affine2(z, time);
      colorWeight = 0.67;
    }

    // Apply nonlinear variation
    z = applyVariation(zt, var_id);

    // Accumulate density: how close does the orbit come back to the original point?
    float d = length(z - p);
    density += exp(-8.0 * d * d);

    // Bail if diverging
    if (dot(z, z) > 100.0) break;
  }

  return density;
}

const int MAX_ITERS = 200;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int var_id = int(clamp(uVariation, 0.0, 40.0));
  int sym = int(clamp(uSymmetry, 0.0, 3.0));
  int schemeInt = int(uColorScheme);
  float time = uTime * 0.01;

  // Compute density at this pixel and two neighbours for normal-map
  float density = flameDensity(p, target, var_id, sym, time);

  // Normalize density
  float norm = density / max(1.0, float(target) * 0.15);
  float logDens = log(1.0 + norm * 5.0) / log(6.0);

  // Normal-map shading (colorScheme 50-63)
  if (schemeInt >= 50) {
    float eps = 0.002 / max(0.000001, uZoom);
    float dR = flameDensity(p + vec2(eps, 0.0), target, var_id, sym, time);
    float dU = flameDensity(p + vec2(0.0, eps), target, var_id, sym, time);
    float nR = log(1.0 + dR / max(1.0, float(target) * 0.15) * 5.0) / log(6.0);
    float nU = log(1.0 + dU / max(1.0, float(target) * 0.15) * 5.0) / log(6.0);

    vec2 grad = vec2(nR - logDens, nU - logDens) / eps;
    float gLen = length(grad);
    vec2 nv = (gLen > 1e-6) ? grad / gLen : vec2(0.0);

    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(logDens * 1.5 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  if (logDens < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Color by density
  float t = fract(logDens * 1.5 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);

  // Modulate brightness by density
  col *= smoothstep(0.0, 0.3, logDens) * 1.2;
  col = clamp(col, 0.0, 1.0);

  float alpha = (uTransparentBg > 0.5) ? smoothstep(0.0, 0.05, logDens) : 1.0;
  fragColor = vec4(linearToSRGB(col), alpha);
}
