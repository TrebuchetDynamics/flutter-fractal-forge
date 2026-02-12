#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b * cos(6.28318 * (c * t + d)); }
vec3 getPaletteColor(float t, int s) {
  t = fract(t);
  if (s == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (s == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (s == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.00, 0.15, 0.20));
  if (s == 3) return vec3(0.5 + 0.5 * cos(6.28318 * t));
  float fs = float(s);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37 * fs + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29 * fs + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11 * fs + 0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (fs + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }

vec2 zetaApprox(vec2 s, int terms) {
  vec2 sum = vec2(0.0);
  for (int n = 1; n <= 32; n++) {
    if (n > terms) break;
    float lnN = log(float(n));
    float amp = exp(-s.x * lnN);
    float ph = -s.y * lnN;
    sum += amp * vec2(cos(ph), sin(ph));
  }
  return sum;
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fc - 0.5 * uResolution) / max(1.0, scale);

  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = c;

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int terms = int(clamp(6.0 + float(target) * 0.05, 6.0, 32.0));
  float bailoutSq = max(4.0, uBailout * uBailout);
  int it = 0;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) { it = target; break; }
    z = zetaApprox(z, terms) + c;
    if (dot(z, z) > bailoutSq) { it = i; break; }
    it = i + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float mag2 = max(1e-8, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2 + 1.0));
  float t = fract(smoothVal / max(1.0, uIterations) + 0.015 * float(terms) + uTime * 0.00007);
  fragColor = vec4(getPaletteColor(t, int(uColorScheme)), 1.0);
}
