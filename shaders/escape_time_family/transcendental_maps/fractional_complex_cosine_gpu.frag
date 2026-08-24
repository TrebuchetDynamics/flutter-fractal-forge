#include <flutter/runtime_effect.glsl>

precision highp float;

// Fractional-order complex cosine map (fractional-inspired transcendental).
// z_{n+1} = order * cos(z_n) + c,  with an extra fractional-power twist:
// cos(z) = cos(x)cosh(y) - i sin(x)sinh(y). The "order" exponent deforms the
// cosine lobes. Naming is deliberately conservative: this is a cosine escape
// map with an order/weight control, inspired by fractional-order cosine-map
// literature, not a claim of exact fractional calculus.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uOrder;         // 10
uniform float uMode;          // 11 (0=translation,1=Lorentz-style modulation)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 ccos(vec2 z) {
  return vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y));
}

vec3 palette(float t, float s) {
  int scheme = int(clamp(floor(s + 0.5), 0.0, 63.0));
  if (scheme == 0) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.4)), 0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  if (scheme == 1) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)), 0.5 + 0.5 * cos(6.28318 * (t + 0.3)), 0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  if (scheme == 2) return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)), 0.5 + 0.5 * cos(6.28318 * (t + 0.33)), 0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float sf = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * sf + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * sf + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * sf + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (sf + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c * t + d)), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 c = uv * 3.0 / max(uZoom, 0.0001) + uCenter;
  float order = max(uOrder, 0.3);
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 1.0));

  int maxIter = int(clamp(uIterations, 20.0, 240.0));
  float bail = max(uBailout, 2.0);
  vec2 z = vec2(0.0, 0.0);
  float iter = 0.0;
  for (int i = 0; i < 240; i++) {
    if (i >= maxIter) break;
    vec2 cz = ccos(z);
    // Fractional order: rotate/scale the iterate, or impact the added term.
    float ang = atan(cz.y, cz.x);
    float mag = length(cz);
    if (mode == 0) {
      z = vec2(cos(ang) * pow(mag, order), sin(ang) * pow(mag, order)) + c;
    } else {
      z = vec2(cos(ang * order) * mag, sin(ang * order) * mag) + c;
    }
    float r2 = dot(z, z);
    if (r2 > bail * bail || r2 < 1e-12) break;
    iter += 1.0;
  }

  float t = iter / float(maxIter);
  vec3 color = palette(fract(t * 4.1), uColorScheme);
  float interior = smoothstep(0.999, 0.9995, t);
  color = mix(color, color * 0.22, interior);
  float alpha = uTransparentBg > 0.5 ? (interior < 0.5 ? 1.0 : 0.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
