#include <flutter/runtime_effect.glsl>
precision highp float;

// Gaussian primes a+bi: off-axis points are prime when a^2+b^2 is an
// ordinary prime; axis points require |a| or |b| prime and congruent to 3 mod 4.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uScale;
uniform float uMode;
out vec4 fragColor;

int imod(int a, int b) {
  return a - (a / b) * b;
}

bool primeInt(int n) {
  if (n < 2) return false;
  if (n == 2) return true;
  if (imod(n, 2) == 0) return false;
  for (int divisor = 3; divisor <= 127; divisor += 2) {
    if (divisor * divisor > n) break;
    if (imod(n, divisor) == 0) return false;
  }
  return true;
}

vec3 pal(float t, float s) {
  float k = floor(s + 0.5);
  return clamp(
    0.5 + 0.5 * cos(6.283185 * (vec3(t) + vec3(0.1 * k, 0.34 + 0.02 * k, 0.67 + 0.04 * k))),
    0.0,
    1.0
  );
}

vec3 srgb(vec3 c) {
  c = clamp(c, 0.0, 1.0);
  return mix(
    12.92 * c,
    1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055,
    step(vec3(0.0031308), c)
  );
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float size = max(1.0, min(uResolution.x, uResolution.y));
  vec2 p = ((fc - 0.5 * uResolution) / size / max(uZoom, 0.001) + uCenter)
    * clamp(uScale, 8.0, 80.0);
  vec2 cell = floor(p + 0.5);
  vec2 local = fract(p + 0.5) - 0.5;
  int a = int(abs(cell.x));
  int b = int(abs(cell.y));
  bool gaussianPrime = false;

  if (a > 0 && b > 0) {
    gaussianPrime = primeInt(a * a + b * b);
  } else {
    int axisValue = a > b ? a : b;
    gaussianPrime = primeInt(axisValue) && imod(axisValue, 4) == 3;
  }

  float dotMask = 1.0 - smoothstep(0.16, 0.43, length(local));
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 2.0));
  float angle = fract(atan(cell.y, cell.x) / 6.283185 + 1.0);
  float norm = sqrt(float(a * a + b * b));
  float t = mode == 0
    ? angle
    : mode == 1
      ? fract(norm * 0.1618)
      : fract(float(imod(a * a + b * b, 12)) / 12.0);
  vec3 bg = vec3(0.008, 0.012, 0.025)
    + 0.035 * (1.0 - smoothstep(0.47, 0.5, max(abs(local.x), abs(local.y))));
  vec3 col = mix(bg, pal(t, uColorScheme), gaussianPrime ? dotMask : 0.0);
  float alpha = uTransparentBg > 0.5
    ? max(0.12, gaussianPrime ? dotMask : 0.0)
    : 1.0;
  fragColor = vec4(srgb(col), alpha);
}
