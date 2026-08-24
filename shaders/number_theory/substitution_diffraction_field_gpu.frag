#include <flutter/runtime_effect.glsl>
precision highp float;

// Finite diffraction of automatic/substitution sequences: Thue-Morse,
// Rudin-Shapiro, and Fibonacci/Sturmian. Intensity is |sum w_n e^-2piikn|^2.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uSequence;
uniform float uMode;
out vec4 fragColor;

int imod(int a, int b) {
  return a - (a / b) * b;
}

float thue(int n) {
  int bits = n;
  int parity = 0;
  for (int i = 0; i < 16; i++) {
    if (bits == 0) break;
    parity += imod(bits, 2);
    bits /= 2;
  }
  return imod(parity, 2) == 0 ? 1.0 : -1.0;
}

float rudin(int n) {
  int bits = n;
  int previous = 0;
  int pairs = 0;
  for (int i = 0; i < 16; i++) {
    int bit = imod(bits, 2);
    if (bit == 1 && previous == 1) pairs++;
    previous = bit;
    bits /= 2;
  }
  return imod(pairs, 2) == 0 ? 1.0 : -1.0;
}

float fibword(int n) {
  float phi = 1.61803398875;
  int a = int(floor(float(n + 1) * phi)) - int(floor(float(n) * phi));
  return a == 1 ? 1.0 : -1.0;
}

vec3 pal(float t, float s) {
  float k = floor(s + 0.5);
  return clamp(
    0.5 + 0.5 * cos(6.283185 * (vec3(t) + vec3(0.09 * k, 0.33 + 0.03 * k, 0.67 + 0.04 * k))),
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
  vec2 p = (fc - 0.5 * uResolution) / size / max(uZoom, 0.001) + uCenter;
  float k = p.x;
  int cap = int(clamp(uIterations, 16.0, 128.0));
  int sequence = int(clamp(floor(uSequence + 0.5), 0.0, 2.0));
  vec2 amplitude = vec2(0.0);
  float local = 0.0;

  for (int n = 0; n < 128; n++) {
    if (n >= cap) break;
    float weight = sequence == 0
      ? thue(n)
      : (sequence == 1 ? rudin(n) : fibword(n));
    float phase = -6.283185 * k * float(n);
    amplitude += weight * vec2(cos(phase), sin(phase));
    if (abs(p.x - float(n) / float(cap)) < 0.004) local = weight;
  }

  float denominator = float(cap) * float(cap);
  float intensity = dot(amplitude, amplitude) / denominator;
  int mode = int(clamp(floor(uMode + 0.5), 0.0, 2.0));
  float graph = 1.0 - smoothstep(0.008, 0.025, abs(p.y - intensity));
  float bars = step(p.y, intensity) * step(0.0, p.y);
  float t = mode == 0
    ? fract(log(1.0 + intensity * 80.0) * 0.35)
    : mode == 1
      ? fract(atan(amplitude.y, amplitude.x) / 6.283185 + 1.0)
      : fract(0.5 + 0.5 * local);
  vec3 bg = pal(fract(k * 0.2), uColorScheme) * 0.04;
  float mask = mode == 0
    ? max(graph, 0.45 * bars)
    : mode == 1
      ? clamp(intensity * 5.0, 0.0, 1.0)
      : clamp(abs(local), 0.0, 1.0);
  vec3 col = mix(bg, pal(t, uColorScheme), mask);
  float alpha = uTransparentBg > 0.5
    ? clamp(intensity * 5.0 + graph, 0.08, 1.0)
    : 1.0;
  fragColor = vec4(srgb(col), alpha);
}
