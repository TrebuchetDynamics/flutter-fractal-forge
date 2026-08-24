#include <flutter/runtime_effect.glsl>

precision highp float;

// Fixed-point iteration fractals (Mann / Ishikawa / Noor / SP).
// The classical Mandelbrot iteration z_{n+1}=z_n^2+c is replaced by weighted
// fixed-point schemes that interpolate between Julia and parameter-space
// forms, producing smoother self-similar variants.
//
//   Mann:      z' = (1-a) z + a f(z)
//   Ishikawa:  z' = (1-a) z + a f((1-b) z + b f(z))
//   Noor:      z' = (1-a) z + a f( (1-b)z + b f( (1-g)z + g f(z) ) )
//   SP:        z' = (1-a) z + a w, w = (1-b) z + b f(z)
//
// where f(z) = z^2 + c (Mandelbrot form, z0=0, c=pixel).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uScheme;        // 10 (0=Mann,1=Ishikawa,2=Noor,3=SP)
uniform float uAlpha;         // 11
uniform float uBeta;          // 12
uniform float uGamma;         // 13

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 cadd(vec2 a, vec2 b) { return a + b; }

vec2 fmap(vec2 z, vec2 c) { return cmul(z, z) + c; }

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
  int scheme = int(clamp(floor(uScheme + 0.5), 0.0, 3.0));
  float a = clamp(uAlpha, 0.05, 1.0);
  float b = clamp(uBeta, 0.05, 1.0);
  float g = clamp(uGamma, 0.05, 1.0);
  int maxIter = int(clamp(uIterations, 20.0, 240.0));
  float bail = max(uBailout, 2.0);

  vec2 z = vec2(0.0, 0.0);
  float iter = 0.0;
  for (int i = 0; i < 240; i++) {
    if (i >= maxIter) break;
    vec2 fz = fmap(z, c);
    vec2 zn;
    if (scheme == 0) {
      zn = (1.0 - a) * z + a * fz;
    } else if (scheme == 1) {
      vec2 w = (1.0 - b) * z + b * fz;
      zn = (1.0 - a) * z + a * fmap(w, c);
    } else if (scheme == 2) {
      vec2 u1 = (1.0 - g) * z + g * fz;
      vec2 u2 = (1.0 - b) * z + b * fmap(u1, c);
      zn = (1.0 - a) * z + a * fmap(u2, c);
    } else {
      vec2 w = (1.0 - b) * z + b * fz;
      zn = (1.0 - a) * z + a * w;
    }
    z = zn;
    float r2 = dot(z, z);
    // Weighted schemes can stay bounded with |z| large but |z-c| small; bail
    // on either the origin radius or the displacement from c.
    float d2 = dot(z - c, z - c);
    if (r2 > bail * bail || d2 > 4.0 * bail * bail) break;
    iter += 1.0;
  }

  float t = iter / float(maxIter);
  float fracIter = t;
  vec3 color = palette(fract(fracIter * 3.7), uColorScheme);
  // Fade the interior (no escape) to background.
  float interior = smoothstep(0.999, 0.9995, t);
  color = mix(color, color * 0.22, interior);
  float alpha = uTransparentBg > 0.5 ? (interior < 0.5 ? 1.0 : 0.0) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
