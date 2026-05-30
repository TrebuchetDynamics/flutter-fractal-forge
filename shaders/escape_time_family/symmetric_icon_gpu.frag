#include <flutter/runtime_effect.glsl>

precision highp float;

// Symmetric Icon map — z' = (lambda + alpha*|z|^2 + beta*Re(z^n))*z + gamma*conj(z)^(n-1).
// Complex-plane discrete map with n-fold symmetry; escape-time coloring.
uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uParamLambda;  // slot 10, default 2.409
uniform float uParamAlpha;   // slot 11, default -2.5
uniform float uParamN;       // slot 12, default 5.0

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

// Complex power: z^n via polar form
vec2 cpow(vec2 z, float n) {
  float r = length(z);
  if (r < 1e-10) return vec2(0.0);
  float theta = atan(z.y, z.x);
  float rn = pow(r, n);
  return rn * vec2(cos(n * theta), sin(n * theta));
}

// Complex multiply
vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = p;

  float lambda = uParamLambda;
  float alpha  = uParamAlpha;
  float n      = floor(uParamN + 0.5);  // integer fold symmetry
  float beta   = 0.3;   // fixed for visual appeal
  float gamma  = 1.0;   // fixed

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailoutSq = max(4.0, uBailout * uBailout);
  int it = target;
  float density = 0.0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    float r2 = dot(z, z);
    vec2 zn = cpow(z, n);
    float reZn = zn.x;
    vec2 zConj = vec2(z.x, -z.y);
    vec2 conjPow = cpow(zConj, n - 1.0);

    float coeff = lambda + alpha * r2 + beta * reZn;
    vec2 nz = coeff * z + gamma * conjPow;
    z = nz;

    float nr2 = dot(z, z);
    density += exp(-0.25 * nr2);
    if (nr2 > bailoutSq) { it = i + 1; break; }
  }

  if (it >= target) {
    float t = fract((density / float(target)) * 1.5 + uTime * 0.00005);
    vec3 col = getPaletteColor(t, int(uColorScheme));
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float r2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(r2));
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(getPaletteColor(t, int(uColorScheme))), 1.0);
}
