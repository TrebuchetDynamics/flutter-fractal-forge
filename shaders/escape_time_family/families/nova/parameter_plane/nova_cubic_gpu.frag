#include <flutter/runtime_effect.glsl>

precision highp float;

// Nova Cubic fractal: z_{n+1} = (2z³+1)/(3z²) + c.
// Mandelbrot analogue — pixel = c, z₀ = (1, 0) (avoids pole at z=0).
// The Nova fractal generalises Newton's method by adding a complex parameter c
// at each step: z_{n+1} = z − (z^n−1)/(n·z^(n−1)) + c.
// For degree 3: z − (z³−1)/(3z²) + c = (2z³+1)/(3z²) + c.
// The Nova cubic has three attracting fixed points (the cube roots of unity)
// plus escaping orbits that form the "Mandelbrot-like" boundary in c-space.
// The main body of the Nova cubic shows a clover-leaf cardioid with three
// primary bulbs; zooming reveals infinite copies of the classical Newton z³ fractal
// embedded in the boundary at all scales.
// Supports normal-map shading (colorScheme 50-63).
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

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
  return clamp(a+b*cos(6.28318*(c4*t+d)),0.0,1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b,b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x*b.x+a.y*b.y, a.y*b.x-a.x*b.y)/d;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);

  int schemeInt = int(uColorScheme);
  vec2 c   = uv / max(0.000001, uZoom) + uCenter;  // Mandelbrot: pixel = c
  vec2 z   = vec2(1.0, 0.0);  // z₀ = 1 (avoids pole at z=0)
  vec2 der = vec2(0.0, 0.0);  // Mandelbrot: der₀ = 0

  float bailoutSq = max(uBailout * uBailout, 16.0);
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    vec2 z2 = cmul(z, z);
    vec2 z3 = cmul(z2, z);
    // f(z) = z³−1, f'(z) = 3z²
    // Newton step: (z³−1)/(3z²) = (z - 1/z²)/3
    // z_next = z − (z³−1)/(3z²) + c = (2z³+1)/(3z²) + c
    vec2 newton_step = cdiv(z3 - vec2(1.0, 0.0), 3.0 * z2);
    // Derivative (Mandelbrot mode, +1): d/dc[z_next] = -f''/(3f'²)·der + 1
    // Simplified: der = (1 - (z³−1)/(z³))·der + 1 ≈ der·(1/z³) + 1
    // More precisely: d(z_next)/dc = d(z-newton_step)/dc + 1
    // = (1 - d(newton_step)/dz)·der + 1
    // d(newton_step)/dz = d((z³-1)/(3z²))/dz = (3z²·3z²-(z³-1)·6z)/(9z⁴)
    //   = (9z⁴-6z⁴+6z)/(9z⁴) = (3z⁴+6z)/(9z⁴) = (z³+2)/(3z³)
    // So: der = (1 - (z³+2)/(3z³))·der + 1 = ((2z³-2)/(3z³))·der + 1
    vec2 dF = cdiv(2.0*(z3 - vec2(1.0,0.0)), 3.0*z3);
    der = cmul(dF, der) + vec2(1.0, 0.0);
    z = z - newton_step + c;
    if (dot(z,z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  float mag2      = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) / log2(3.0);

  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom2 = max(1e-12, dot(der, der));
    vec2 nv = vec2(z.x*der.x+z.y*der.y, z.y*der.x-z.x*der.y) / denom2;
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
