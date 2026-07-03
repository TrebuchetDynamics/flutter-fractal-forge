// ── Shared math constants and helpers ────────────────────────────────────

#ifndef SHARED_MATH_GLSL
#define SHARED_MATH_GLSL

#define PI_GLSL 3.14159265359

// Simple pseudo-random hash (used for seed generation in attractors).
float hash21(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

#endif // SHARED_MATH_GLSL