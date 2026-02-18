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

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b * cos(6.28318 * (c * t + d)); }
vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 c2 = uv / max(0.000001, uZoom) + uCenter;
  vec3 z = vec3(c2, 0.25 * sin(0.0007 * uTime));
  vec3 c = vec3(c2 * 0.75, 0.25);

  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  float bailout = max(2.0, uBailout);
  int it = target;
  float trap = 1e9;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= target) break;

    float r = length(z);
    if (r > bailout) { it = i + 1; break; }

    float theta = acos(clamp(z.z / max(r, 1e-6), -1.0, 1.0));
    float phi = atan(z.y, z.x);
    float power = 2.6 + 0.4 * sin(0.0003 * uTime);
    float zr = pow(max(r, 1e-6), power);

    theta *= power;
    phi = phi * power + 0.15 * sin(3.0 * phi + 0.1 * float(i));

    z = zr * vec3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
    z.xy = abs(z.xy) - vec2(0.35, 0.18);
    z += c;

    trap = min(trap, dot(z.xy, z.xy) + 0.3 * abs(z.z));
  }

  if (it >= target) {
    float t = fract(0.35 * log(1.0 + 1.0 / max(1e-6, trap)) + 0.08 * atan(z.y, z.x));
    fragColor = vec4(linearToSRGB(getPaletteColor(t + uTime * 0.00003, int(uColorScheme))), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float m2 = dot(z, z);
  float smoothVal = float(it) - log2(log2(max(1.0001, m2)));
  float t = fract(smoothVal / 64.0 + 0.2 * log(1.0 + 1.0 / max(1e-6, trap)));
  fragColor = vec4(linearToSRGB(getPaletteColor(t, int(uColorScheme))), 1.0);
}
