// ── Complex number arithmetic helpers (include in fractal shaders) ──────
//   cmul(a, b)  — complex multiplication
//   cdiv(a, b)  — complex division (safe)
//   cexp(z)     — complex exponential exp(z) = e^x·(cos y + i·sin y)
//   rotate(p,a) — 2D rotation by angle a
//
// cexp uses a configurable clamp on the real component for numeric stability.
// Default: ±40. Override by defining CEXP_CLAMP before including this file.
// Example:  #define CEXP_CLAMP -88.0
//           #include "../shared/complex.glsl"
//
// If a shader needs a completely custom cexp (different structure), define
// HAS_LOCAL_CEXP before including to skip the shared version.
// Example:  #define HAS_LOCAL_CEXP
//           #include "../shared/complex.glsl"

#ifndef CEXP_CLAMP
#define CEXP_CLAMP -40.0
#endif

#ifndef HAS_LOCAL_CEXP
vec2 cexp(vec2 z) {
  float ex = exp(clamp(z.x, CEXP_CLAMP, -CEXP_CLAMP));
  return ex * vec2(cos(z.y), sin(z.y));
}
#endif

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }

vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b, b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

vec2 rotate(vec2 p, float a) {
  float c = cos(a), s = sin(a);
  return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}