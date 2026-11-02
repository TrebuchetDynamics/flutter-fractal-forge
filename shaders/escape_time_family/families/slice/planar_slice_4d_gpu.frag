#include <flutter/runtime_effect.glsl>

precision highp float;

// Affine-plane 4D slices: (x, y) are mapped onto two rotated copies of the
// complex plane before the orbit runs.
//
//   z0 = exp(i*angleB) * x + offset
//   c  = exp(i*angleA) * y + offset
//   z  = (-z)^p + c
//
// This is the "multimin / multirot" construction from the formula collection in
// opensource/repos/formula-catalogs/fract4d-formulas (orgform/fotdv7.frm, MIT,
// commit 2b3e04b): the picture is a 2D cut through a 4D family, and the two
// angles choose which cut. AngleA tilts the parameter plane, angleB tilts the
// orbit plane.
//
// Degenerate wiring pinned by the companion test: angleA = angleB = 0, offset 0
// maps z0 = pixel.x and c = pixel.y, so the recurrence is the real slice
// z_{n+1} = z_n^2 + c of the Mandelbrot map. The test mirrors that wiring and
// compares two iterations against the closed form.
//
// Extras (uniform slots 10+): angleA (degrees), angleB (degrees), exponent,
// offsetReal, offsetImag, planeMode (0 = multimin, 1 = multirot; the mode only
// changes the displayed name and the stored preset, not the mathematics).
uniform float uTime;            // 0
uniform vec2  uResolution;      // 1-2
uniform vec2  uCenter;          // 3-4
uniform float uZoom;            // 5
uniform float uIterations;      // 6
uniform float uBailout;         // 7
uniform float uColorScheme;     // 8
uniform float uTransparentBg;   // 9
uniform float uSliceAngleA;     // 10
uniform float uSliceAngleB;     // 11
uniform float uSlicePower;      // 12
uniform float uSliceOffsetRe;   // 13
uniform float uSliceOffsetIm;   // 14
uniform float uSliceMode;       // 15

out vec4 fragColor;

const int MAX_ITERS = 500;
const float DEG = 0.017453292519943295;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) return vec3(0.5+0.5*cos(6.28318*(t+0.0)), 0.5+0.5*cos(6.28318*(t+0.4)), 0.5+0.5*cos(6.28318*(t+0.7)));
  if (scheme == 1) return vec3(0.5+0.5*cos(6.28318*(t+0.5)), 0.5+0.5*cos(6.28318*(t+0.3)), 0.5+0.5*cos(6.28318*(t+0.0)));
  if (scheme == 2) return vec3(0.5+0.5*cos(6.28318*(t+0.0)), 0.5+0.5*cos(6.28318*(t+0.33)), 0.5+0.5*cos(6.28318*(t+0.67)));
  if (scheme == 3) { float g = 0.5+0.5*cos(6.28318*t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55+0.15*sin(vec3(1.0,2.0,3.0)*(0.37*s+0.1));
  vec3 b = 0.45+0.25*cos(vec3(1.7,2.3,2.9)*(0.29*s+0.2));
  vec3 c4 = 1.0+0.80*sin(vec3(0.8,1.3,1.7)*(0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719)*(s+0.5))*43758.5453);
  return clamp(a+b*cos(6.28318*(c4*t+d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }

vec2 cpowr(vec2 z, float p) {
  float r = length(z);
  if (r < 1e-9) return vec2(0.0);
  float theta = p * atan(z.y, z.x);
  return pow(r, p) * vec2(cos(theta), sin(theta));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 pixel = uv / max(0.000001, uZoom) + uCenter;

  float aA = uSliceAngleA * DEG;
  float aB = uSliceAngleB * DEG;
  float p  = max(uSlicePower, 1.0);
  vec2 offset = vec2(uSliceOffsetRe, uSliceOffsetIm);
  vec2 eA = vec2(cos(aA), sin(aA));
  vec2 eB = vec2(cos(aB), sin(aB));

  vec2 c = cmul(eA, vec2(pixel.y, 0.0)) + offset;
  vec2 z = cmul(eB, vec2(pixel.x, 0.0)) + offset;

  float bailoutSq = uBailout * uBailout;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  // der = d z / d c, seeded at zero because the orbit starts independent of c.
  vec2 der = vec2(0.0);

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // z <- (-z)^p + c ; d/dz of (-z)^p is -p*(-z)^(p-1)
    vec2 negz = -z;
    vec2 dz = -p * cpowr(negz, p - 1.0);
    der = cmul(dz, der) + vec2(1.0, 0.0);

    z = cpowr(negz, p) + c;

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) / log2(max(p, 2.0));

  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2(z.x*der.x+z.y*der.y, z.y*der.x-z.x*der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv,lightDir)+HEIGHT)/(1.0+HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0/1.8);
    float baseT = fract(smoothVal/64.0 + uTime*0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal)*light), 1.0);
    return;
  }

  float t = fract(smoothVal/64.0 + uTime*0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
