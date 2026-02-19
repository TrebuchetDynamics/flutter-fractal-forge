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

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318530718 * (c * t + d));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) return clamp(iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.2, 0.4)), 0.0, 1.0);
  if (scheme == 1) return clamp(iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.3, 0.2, 0.1)), 0.0, 1.0);
  if (scheme == 2) return clamp(iqPalette(t, vec3(0.55), vec3(0.45), vec3(1.0), vec3(0.1, 0.3, 0.5)), 0.0, 1.0);
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 d = fract(sin(vec3(17.23, 43.11, 91.7) * (s + 0.4)) * 12345.678);
  return clamp(iqPalette(t, vec3(0.52), vec3(0.48), vec3(1.0), d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = vec2(0.0);
  vec2 zPrev = vec2(0.0);
  vec2 zPrev2 = vec2(0.0);

  float escapeSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;
  bool escaped = false;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    zPrev2 = zPrev;
    zPrev = z;
    z = cmul(z, z) + c;

    if (dot(z, z) > escapeSq) {
      escaped = true;
      it = j;
      break;
    }
    it = j + 1;
  }

  if (escaped) {
    float mu = float(it);
    float z2 = dot(z, z);
    if (z2 > 1.0) {
      mu = float(it) + 1.0 - log2(0.5 * log(z2));
    }
    float t = fract(mu / max(1.0, uIterations) + uTime * 0.0001);
    fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
    return;
  }

  // Interior Fatou coloring by period hint / attractor behavior.
  float d1 = length(z - zPrev);
  float d2 = length(z - zPrev2);
  float periodHint = (d1 < d2) ? 1.0 : 2.0;
  float attractorPhase = fract(0.2 * atan(z.y, z.x) / 3.14159265 + 0.5);
  float t = fract(0.5 * periodHint + attractorPhase + 0.2 * log(1.0 + length(z)) + uTime * 0.00005);

  vec3 col = palette(t, int(uColorScheme));
  col = mix(col, vec3(0.08, 0.05, 0.12), 0.25);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
