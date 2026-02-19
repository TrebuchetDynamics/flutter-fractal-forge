#include <flutter/runtime_effect.glsl>

precision highp float;

// Newton fractal for z^5 − 1 = 0.
// Five roots at e^{2πik/5}, k=0..5: the vertices of a regular pentagon.
// z_{n+1} = z − (z^5 − 1) / (5z^4) = (4z^5 + 1) / (5z^4).
// The five-fold symmetry produces a star-shaped basin structure with
// intricate secondary spirals along each Fatou component boundary.
// Root basins colored at phases 0, 1/5, 2/5, 3/5, 4/5.
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
  vec3 c = 1.0 +0.80*sin(vec3(0.8,1.3,1.7)*(0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719)*(s+0.5))*43758.5453);
  return clamp(a+b*cos(6.28318*(c*t+d)),0.0,1.0);
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

  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    vec2 z2 = cmul(z, z);
    vec2 z4 = cmul(z2, z2);
    vec2 z5 = cmul(z4, z);
    vec2 fz  = z5 - vec2(1.0, 0.0);  // z^5 - 1
    vec2 fpz = 5.0 * z4;              // 5z^4
    vec2 step = cdiv(fz, fpz);
    z = z - step;
    if (dot(step,step) < 1e-12)               { it = j; break; }
    if (dot(z,z) > max(uBailout*uBailout, 64.0)) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  // 5 roots at e^{2πik/5}: cos(72k°), sin(72k°)
  // cos72≈0.309, sin72≈0.951, cos144≈-0.809, sin144≈0.588
  vec2 roots[5];
  roots[0] = vec2( 1.0,      0.0);
  roots[1] = vec2( 0.30902,  0.95106);
  roots[2] = vec2(-0.80902,  0.58779);
  roots[3] = vec2(-0.80902, -0.58779);
  roots[4] = vec2( 0.30902, -0.95106);

  int closest = 0;
  float minD = dot(z-roots[0], z-roots[0]);
  for (int k = 1; k < 5; k++) {
    float dk = dot(z-roots[k], z-roots[k]);
    if (dk < minD) { minD = dk; closest = k; }
  }

  float rootPhase = float(closest) / 5.0;
  float t = fract(float(it)/max(1.0,uIterations) + rootPhase + uTime*0.0001);
  fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
}
