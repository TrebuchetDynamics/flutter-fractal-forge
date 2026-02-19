#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbrot Stripe Average Coloring
// During iteration accumulates sin(N*arg(z)) and averages over orbit length.
// The stripe frequency N (via uBailout repurposed as frequency 1-16) controls
// stripe density. Produces bold interference patterns unlike standard escape-
// time coloring. Interior pixels are darkened to distinguish the boundary.
// colorScheme 50-63: normal-map (bas-relief) mode — 14 light angles × 4 palettes.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7  (also used as stripe frequency: integer 1-16)
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

// colorScheme 0-49: standard palette; 50-63: normal-map bas-relief.
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
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = vec2(0.0);

  // Stripe frequency: integer 1-16 encoded in uBailout (default 4.0 → freq 4).
  float stripeFreq = clamp(floor(uBailout), 1.0, 16.0);
  float bailoutSq  = 256.0; // fixed large bailout for stripe accuracy

  // Derivative for normal-map mode.
  vec2 der = vec2(0.0);

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  // Stripe accumulator: sum of 0.5+0.5*sin(freq*arg(z)) over orbit.
  float stripeSum = 0.0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Derivative update before z update.
    der = 2.0 * vec2(z.x*der.x - z.y*der.y, z.x*der.y + z.y*der.x) + vec2(1.0, 0.0);

    z = vec2(z.x*z.x - z.y*z.y + c.x, 2.0*z.x*z.y + c.y);

    // Accumulate stripe value using argument of z.
    stripeSum += 0.5 + 0.5 * sin(stripeFreq * atan(z.y, z.x));

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  bool escaped = (it < target);

  if (!escaped && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }

  // Stripe average (normalized to [0,1]).
  float avg = (it > 0) ? stripeSum / float(it + 1) : 0.0;

  // Smooth escape value for interpolation.
  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = escaped ? (float(it) - log2(log2(mag2)) + 4.0) : 0.0;

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;
    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);
    // Blend stripe avg into color phase for the normal-map base palette.
    float baseT = fract(avg + uTime * 0.0001);
    int basePal = (schemeInt - 50) % 4;
    vec3 col = palette(baseT, basePal) * light;
    if (!escaped) col *= 0.4;
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  // Standard stripe-average color: use avg as primary hue driver.
  // Smooth-blend between adjacent stripe bands using smoothVal fraction.
  float frac   = fract(smoothVal);
  float stripeA = fract(avg + uTime * 0.0001);
  float stripeB = fract(avg + 1.0 / max(1.0, uIterations) + uTime * 0.0001);
  float t = mix(stripeA, stripeB, frac);

  vec3 col = palette(t, schemeInt);
  if (!escaped) col *= 0.4;
  fragColor = vec4(linearToSRGB(col), 1.0);
}
