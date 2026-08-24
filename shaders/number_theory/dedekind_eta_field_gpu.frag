#include <flutter/runtime_effect.glsl>

precision highp float;

// Dedekind eta-function fractal field (upper half-plane).
// eta(tau) = q^(1/24) * prod_{n>=1} (1 - q^n),  q = e^(2 pi i tau), Im tau > 0.
// |eta|, arg(eta), Re(eta) and the modular-group fundamental-domain
// tessellation produce self-similar lace. Naming is conservative: this is a
// q-product field / Eisenstein-style modular lace, not a full modular-form
// arithmetic claim.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6 (used as max q-product terms N)
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uMode;          // 10 (0=|eta|,1=arg(eta),2=Re(eta),3=tessellation)

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// Complex subtraction product helper.
vec2 cminus1(vec2 q) { return vec2(1.0 - q.x, -q.y); }
vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }

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
  float zoomx = max(uZoom, 0.001);
  // tau = x + i y in the upper half-plane (y > 0).
  float x = uv.x * 1.6 / zoomx + uCenter.x;
  float y = exp(uv.y * 1.5) * 0.4; // expand near the real line for detail
  y = max(y, 0.005);
  int terms = int(clamp(uIterations, 6.0, 40.0));
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 3.0));

  // q = exp(2 pi i tau) = exp(-2 pi y) * (cos(2 pi x) + i sin(2 pi x)).
  float twoPi = 6.28318;
  float qmag = exp(-twoPi * y);
  vec2 q = vec2(qmag * cos(twoPi * x), qmag * sin(twoPi * x));

  // eta(tau): accumulate product (1 - q^n), then multiply by q^(1/24).
  vec2 prod = vec2(1.0, 0.0);
  vec2 qn = vec2(1.0, 0.0); // q^n
  for (int n = 1; n <= 40; n++) {
    if (n > terms) break;
    qn = cmul(qn, q);
    prod = cmul(prod, cminus1(qn));
  }
  // q^(1/24) = exp((1/24) * log q) = qmag^(1/24) * e^(i x / 12).
  float m24 = pow(qmag, 1.0 / 24.0);
  vec2 qRoot = vec2(m24 * cos(x / 12.0), m24 * sin(x / 12.0));
  vec2 eta = cmul(qRoot, prod);

  vec3 color;
  if (mode == 0) {
    float m = length(eta);
    color = palette(fract(m * 3.5 + log(m + 1.0)), uColorScheme);
  } else if (mode == 1) {
    float a = atan(eta.y, eta.x) / 6.28318;
    color = palette(fract(a), uColorScheme);
  } else if (mode == 2) {
    float r = eta.x;
    color = palette(fract(r * 2.0), uColorScheme);
  } else {
    // Modular tessellation: toggle shading along a coarse modular-grid proxy
    // using cos(x) and a periodic height ring.
    float ring = 0.5 + 0.5 * cos(twoPi * (x * 3.0 + y * 2.0));
    float bands = 0.5 + 0.5 * cos(twoPi * x * 6.0);
    color = palette(fract(0.5 * ring + 0.3 * bands), uColorScheme);
  }
  float alpha = uTransparentBg > 0.5 ? 1.0 : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
