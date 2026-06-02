#include <flutter/runtime_effect.glsl>

precision highp float;

// 3D Fractal — from MandlebrotSetSFML formula #9.
// z_{n+1} = |z|² · z + c,  where |z|² = z_real²+z_imag².
// Each component is scaled by the squared magnitude: the orbit grows cubically
// in radius while preserving argument — at low zoom Julia sets appear to have
// 3D depth when rendered with the oscillating-grayscale palette.
// Note: this map is NOT complex-analytic; the Jacobian is a symmetric 2×2
// matrix J = [[3x²+y², 2xy],[2xy, x²+3y²]], used for the normal-map estimate.
// Derivative (Jacobian chain rule, initial seed [1,0]):
//   new_der_x = (3x²+y²)·der_x + 2xy·der_y + 1
//   new_der_y =  2xy·der_x + (x²+3y²)·der_y
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
  if (scheme == 0) return vec3(0.5)+0.5*cos(6.28318*(vec3(t)+vec3(0.0,0.4,0.7)));
  if (scheme == 1) return vec3(0.5)+0.5*cos(6.28318*(vec3(t)+vec3(0.5,0.3,0.0)));
  if (scheme == 2) return vec3(0.5)+0.5*cos(6.28318*(vec3(t)+vec3(0.0,0.33,0.67)));
  if (scheme == 3) { float g = 0.5+0.5*cos(6.28318*t); return vec3(g); }
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
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z   = vec2(0.0);
  vec2 der = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    float x = z.x, y = z.y;
    float zcomp = x*x + y*y;         // |z|²
    float twoXY  = 2.0 * x * y;

    // Jacobian of F(z)=|z|²·z  w.r.t. (z_real,z_imag):
    //   J = [[3x²+y², 2xy], [2xy, x²+3y²]]
    float j00 = 3.0*x*x + y*y;
    float j01 = twoXY;
    float j11 = x*x + 3.0*y*y;

    float new_der_x = j00*der.x + j01*der.y + 1.0;
    float new_der_y = j01*der.x + j11*der.y;
    der = vec2(new_der_x, new_der_y);

    z = zcomp * z + c;               // |z|²·z + c

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x*der.x + z.y*der.y,
                    z.y*der.x - z.x*der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
