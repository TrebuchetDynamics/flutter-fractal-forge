#include <flutter/runtime_effect.glsl>

precision highp float;

// Nova Mandelbrot: z_{n+1} = z - (z^3 - 1)/(3z^2) + c
// Newton's method on z^3 - 1, perturbed by c.
// Convergent-style: color by which root the orbit approaches.
// Three roots of z^3 = 1: (1,0), (-0.5, sqrt(3)/2), (-0.5, -sqrt(3)/2)
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
  vec3 c4 = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c4 * t + d)), 0.0, 1.0);
}

vec2 cx_mul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
vec2 cx_div(vec2 a, vec2 b) { float d = max(1e-20, dot(b,b)); return vec2(dot(a,b), a.y*b.x - a.x*b.y) / d; }

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  // Start from z = 1 (near a root) for interesting dynamics
  vec2 z = vec2(1.0, 0.0);
  float bailoutSq = uBailout * uBailout;

  // Three cube roots of unity
  vec2 root0 = vec2(1.0, 0.0);
  vec2 root1 = vec2(-0.5, 0.866025);
  vec2 root2 = vec2(-0.5, -0.866025);

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  int rootId = -1;
  float convergeDist = 1e-6;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    // z^2
    vec2 z2 = cx_mul(z, z);
    // z^3
    vec2 z3 = cx_mul(z2, z);
    // f(z) = z^3 - 1
    vec2 fz = z3 - vec2(1.0, 0.0);
    // f'(z) = 3z^2
    vec2 fpz = 3.0 * z2;
    // Newton step + perturbation
    z = z - cx_div(fz, fpz) + c;

    // Check convergence to roots
    vec2 d0 = z - root0;
    vec2 d1 = z - root1;
    vec2 d2 = z - root2;
    if (dot(d0, d0) < convergeDist) { it = j; rootId = 0; break; }
    if (dot(d1, d1) < convergeDist) { it = j; rootId = 1; break; }
    if (dot(d2, d2) < convergeDist) { it = j; rootId = 2; break; }

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  // Root-based coloring for convergent points
  if (rootId >= 0) {
    float smoothVal = float(it) + 1.0;
    float t = fract(smoothVal / 64.0 + uTime * 0.0001);
    int pal = schemeInt < 50 ? schemeInt : (schemeInt - 50) % 4;
    vec3 baseCol = palette(t, pal);
    // Tint by root
    if (rootId == 0) baseCol *= vec3(1.0, 0.7, 0.7);
    else if (rootId == 1) baseCol *= vec3(0.7, 1.0, 0.7);
    else baseCol *= vec3(0.7, 0.7, 1.0);
    // Darken by iteration count for depth
    float shade = 1.0 - float(it) / float(target) * 0.5;
    fragColor = vec4(linearToSRGB(baseCol * shade), 1.0);
    return;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(max(1.0, log2(mag2))) + 4.0;

  if (schemeInt >= 50) {
    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    vec2 nv = normalize(z);
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);
    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) % 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
