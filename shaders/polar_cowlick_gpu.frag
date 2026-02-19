#include <flutter/runtime_effect.glsl>

precision highp float;

// Polar Cowlick — from MandlebrotSetSFML formula #23.
// r = |z|;  θ = arg(z);  z_{n+1} = sin(3r) · exp(i·(θ+r)) + c.
// The radius is mapped through sin(3r) (creating 3 radial folds) while the
// angle is rotated by r, producing distinctive swirling cowlick patterns.
// Derivative approx: F'(z) ≈ 3·cos(3r) · (z/|z|)  (radial chain rule).
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

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

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

    float r      = length(z);
    float th     = atan(z.y, z.x);
    float r_new  = sin(3.0 * r);
    float th_new = th + r;

    // Derivative approx: F'(z) ≈ 3·cos(3r) · (z/|z|)  (unit direction of z)
    float dr_dz  = 3.0 * cos(3.0 * r);
    vec2  zDir   = z / max(1e-6, r);   // e^{iθ}, unit direction
    der = cmul(dr_dz * zDir, der) + vec2(1.0, 0.0);

    z = r_new * vec2(cos(th_new), sin(th_new)) + c;

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
    int basePal = (schemeInt - 50) % 4;
    fragColor = vec4(linearToSRGB(palette(baseT, basePal) * light), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, schemeInt)), 1.0);
}
