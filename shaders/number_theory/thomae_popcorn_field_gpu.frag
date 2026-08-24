#include <flutter/runtime_effect.glsl>
precision highp float;

// Thomae's popcorn function: f(p/q)=1/q for reduced rationals and f(x)=0
// for irrationals. Finite denominator scans expose its self-similar spikes.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uMode;
out vec4 fragColor;

int imod(int a, int b) {
  return a - (a / b) * b;
}

int gcdInt(int a, int b) {
  int valueA = a < 0 ? -a : a;
  int valueB = b < 0 ? -b : b;
  for (int i = 0; i < 16; i++) {
    if (valueB == 0) break;
    int remainder = imod(valueA, valueB);
    valueA = valueB;
    valueB = remainder;
  }
  return valueA < 1 ? 1 : valueA;
}

vec3 pal(float t, float s) {
  float k = floor(s + 0.5);
  return clamp(
    0.5 + 0.5 * cos(6.283185 * (vec3(t) + vec3(0.08 * k, 0.34 + 0.03 * k, 0.68 + 0.04 * k))),
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
  vec2 uv = (fc - 0.5 * uResolution) / size / max(uZoom, 0.001) + uCenter;
  float x = uv.x;
  float y = uv.y;
  int cap = int(clamp(uIterations, 4.0, 64.0));
  float best = 0.0;
  float nearest = 1.0;
  float bestQ = float(cap);
  float width = 1.7 / size / max(uZoom, 0.001);

  for (int q = 1; q <= 64; q++) {
    if (q > cap) break;
    int numerator = int(floor(x * float(q) + 0.5));
    float distance = abs(x - float(numerator) / float(q));
    if (gcdInt(numerator, q) == 1 && distance < width) {
      float height = 1.0 / float(q);
      if (height > best) {
        best = height;
        nearest = distance;
        bestQ = float(q);
      }
    }
  }

  int mode = int(clamp(floor(uMode + 0.5), 0.0, 2.0));
  float spike = 1.0 - smoothstep(0.0, 0.012 + 2.0 / size, abs(y - best));
  float stem = best > 0.0
    ? (1.0 - smoothstep(width, 2.5 * width, nearest)) * step(y, best)
    : 0.0;
  float t = mode == 0
    ? fract(bestQ * 0.1618)
    : mode == 1
      ? fract(best * 8.0)
      : fract(x * 13.0 + bestQ * 0.07);
  vec3 bg = pal(fract(x * 0.25 + y * 0.15), uColorScheme) * 0.08;
  vec3 col = mix(bg, pal(t, uColorScheme), max(spike, stem * 0.65));
  float alpha = uTransparentBg > 0.5 ? max(spike, stem) : 1.0;
  fragColor = vec4(srgb(col), alpha);
}
