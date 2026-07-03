#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uRelaxation;     // 10

out vec4 fragColor;

// Shared includes: color.glsl (linearToSRGB, palette), complex.glsl (cmul, cdiv)
#include "../shared/color.glsl"
#include "../shared/complex.glsl"

float rootDistanceSq(vec2 z, vec2 root) {
  vec2 d = z - root;
  return dot(d, d);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;
  vec2 z0 = z;
  float escapeSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    vec2 z2 = cmul(z, z);
    vec2 z3 = cmul(z2, z);
    vec2 f = z3 - vec2(1.0, 0.0);
    vec2 fp = 3.0 * z2;
    vec2 fpp = 6.0 * z;

    vec2 num = 2.0 * cmul(f, fp);
    vec2 den = 2.0 * cmul(fp, fp) - cmul(f, fpp);
    vec2 step = cdiv(num, den);

    z = z - uRelaxation * step;

    if (dot(step, step) < 1e-12) { it = j; break; }
    if (dot(z, z) > max(escapeSq, 64.0)) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    // Short smoke-test iteration caps can leave root basins unconverged;
    // still color by nearest root so the default view is informative.
    it = target > 0 ? target - 1 : 0;
  }

  vec2 r0 = vec2(1.0, 0.0);
  vec2 r1 = vec2(-0.5, 0.86602540378);
  vec2 r2 = vec2(-0.5, -0.86602540378);

  float d0 = rootDistanceSq(z, r0);
  float d1 = rootDistanceSq(z, r1);
  float d2 = rootDistanceSq(z, r2);

  float rootPhase = 0.0;
  if (d1 < d0 && d1 < d2) {
    rootPhase = 0.3333333;
  } else if (d2 < d0 && d2 < d1) {
    rootPhase = 0.6666667;
  }

  float boundary = exp(-18.0 * sqrt(max(0.0, min(d0, min(d1, d2)))));
  float contour = 0.10 * sin(18.0 * z0.x + 11.0 * z0.y) +
      0.06 * sin(31.0 * length(z0));
  float t = fract(float(it) / max(1.0, uIterations) + rootPhase +
      0.12 * boundary + contour + uTime * 0.0001);
  vec3 color = palette(t, int(uColorScheme));
  fragColor = vec4(linearToSRGB(color), 1.0);
}
