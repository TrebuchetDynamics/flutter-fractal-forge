#include <flutter/runtime_effect.glsl>

precision highp float;

// Singularity fractal — from MandlebrotSetSFML formula #11.
// z_{n+1} = (x² − y² + c_x,  2·c_x·y + c_y).
// The imaginary update uses c_x (the fixed real part of c) instead of x_n,
// creating non-standard coupling: the imaginary axis is scaled by c_x each
// iteration. Near c_x=0 the set collapses; near |c_x|=1 it resembles the
// Mandelbrot set with an unusual tilt. Looks "sick" in Julia views.
// Derivative: der_{n+1} = (2x·der_x − 2y·der_y + 1,  2c_x·der_y + 2y).
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

    // Derivative: Jacobian of F w.r.t. c, accounting for c_x in the imaginary term.
    // ∂F_x/∂c = 2x·der_x − 2y·der_y + 1  (same as Mandelbrot)
    // ∂F_y/∂c = 2c_x·der_y + 2z_y        (extra 2z_y term from ∂(2c_x·z_y)/∂c_x)
    float new_der_x = 2.0 * z.x * der.x - 2.0 * z.y * der.y + 1.0;
    float new_der_y = 2.0 * c.x * der.y + 2.0 * z.y;
    der = vec2(new_der_x, new_der_y);

    // z_{n+1} = (x²−y² + c_x,  2·c_x·y + c_y)
    float nx = z.x * z.x - z.y * z.y + c.x;
    float ny = 2.0 * c.x * z.y + c.y;
    z = vec2(nx, ny);

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
