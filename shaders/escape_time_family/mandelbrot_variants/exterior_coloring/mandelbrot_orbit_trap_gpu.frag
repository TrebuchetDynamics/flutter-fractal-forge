#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbrot Orbit Trap (Cross Trap)
// Instead of coloring by escape-iteration count, colors by the minimum
// distance the orbit comes to the real and imaginary axes (the "cross trap").
// Both interior (bounded) and exterior (escaped) pixels are colored by this
// trap distance, revealing rich structure inside the classic black interior.
// Interior pixels are shown at 60% brightness to distinguish the boundary.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uTrapMode;      // 10

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float sdBox(vec2 p, vec2 b) {
  vec2 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-12), 0.0, 1.0);
  return length(pa - ba * h);
}

float fmin2(float a, float b) { return a < b ? a : b; }
float fabs1(float v) { return v < 0.0 ? -v : v; }

float sdStar5(vec2 p) {
  float a = atan(p.y, p.x);
  float r = length(p);
  float k = cos(5.0 * a);
  float targetRadius = mix(0.18, 0.42, smoothstep(-1.0, 1.0, k));
  return fabs1(r - targetRadius);
}

float trapDistance(vec2 z, int mode) {
  vec2 p = z;
  float r = length(p);
  float a = atan(p.y, p.x);
  if (mode == 1) return abs(r - 0.45); // circle / Pickover stalks
  if (mode == 2) return abs(sdBox(p, vec2(0.45))); // square
  if (mode == 3) return r; // point origin
  if (mode == 4) return length(p - vec2(0.37, 0.23)); // custom point
  if (mode == 5) return abs(p.y); // real axis
  if (mode == 6) return abs(p.x); // imaginary axis
  if (mode == 7) return min(abs(p.x), abs(p.y)); // multi-line cross
  if (mode == 8) {
    float heart = pow(p.x*p.x + p.y*p.y - 0.18, 3.0) - p.x*p.x*p.y*p.y*p.y;
    return abs(heart) / (1.0 + 8.0 * r);
  }
  if (mode == 9) return sdStar5(p);
  if (mode == 10) return abs(r - 0.05 * a - 0.12);
  if (mode == 11) return min(sdSegment(p, vec2(-0.2, -0.35), vec2(0.0, 0.4)), sdSegment(p, vec2(0.0, 0.4), vec2(0.22, -0.35))); // text A
  if (mode == 12) return min(abs(p.x + 0.25), min(abs(p.x - 0.25), sdSegment(p, vec2(-0.25, -0.35), vec2(0.0, 0.15)))); // text M
  if (mode == 13) return abs(r - (0.22 + 0.12 * cos(3.0 * a))); // epicycloid-like
  if (mode == 14) return abs(r - 0.35 * abs(cos(3.0 * a))); // rose
  if (mode == 15) return abs(r - (0.28 + 0.18 * cos(a))); // limacon
  if (mode == 16) return abs(r - 0.28 * (1.0 + cos(a))); // cardioid
  if (mode == 17) return abs(r*r - 0.18 * cos(2.0 * a)); // lemniscate
  if (mode == 18) return abs(pow(abs(p.x), 0.6667) + pow(abs(p.y), 0.6667) - 0.55); // astroid
  if (mode == 19) return abs(r - 0.35 * abs(cos(1.5 * a))); // hypocycloid 3-cusp
  if (mode == 20) return min(abs(fract(p.x * 3.0 + 0.5) - 0.5), abs(fract(p.y * 3.0 + 0.5) - 0.5)) / 3.0; // square lattice
  if (mode == 21) return min(abs(fract(p.x * 3.0 + 0.5) - 0.5), abs(fract((p.x * 0.5 + 0.8660254 * p.y) * 3.0 + 0.5) - 0.5)) / 3.0; // hex lattice
  if (mode == 22) return abs(sin(8.0 * a + 3.0 * r)) * 0.12 + abs(r - 0.35) * 0.08; // field lines
  if (mode == 23) return min(min(abs(sdBox(p, vec2(0.38))), abs(r - 0.32)), min(abs(p.x), abs(p.y))); // composite
  if (mode == 24) return abs(fract(r * 6.0) - 0.5) / 6.0; // concentric rings
  return min(abs(p.x), abs(p.y)); // cross
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

  int schemeInt = int(uColorScheme);
  vec2 c   = uv / max(0.000001, uZoom) + uCenter;
  vec2 z   = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 2000;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  // Trap: record minimum distance to selected stable geometry.
  float trap = 1e10;
  int trapMode = int(uTrapMode);

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    z = vec2(z.x*z.x - z.y*z.y + c.x, 2.0*z.x*z.y + c.y);

    trap = fmin2(trap, fabs1(trapDistance(z, trapMode)));

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  bool escaped = (it < target);

  if (!escaped && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Map trap distance to color band using log scale for even banding.
  // trap ∈ [0, ~uBailout]; log maps this to (-∞, ~log(uBailout)].
  // Divide by 3 for ~3-band spread at default zoom.
  float logTrap = -log(max(trap, 1e-20)) / 3.0;
  float t = fract(logTrap + uTime * 0.0001);

  vec3 col = palette(t, schemeInt);

  // Interior (bounded orbit): darken to distinguish from exterior.
  if (!escaped) col *= 0.55;

  fragColor = vec4(linearToSRGB(col), 1.0);
}
