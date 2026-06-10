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
const float PI = 3.14159265359;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-6), 0.0, 1.0);
  return length(pa - ba * h);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 p = uv / max(0.000001, uZoom) + uCenter;
  p *= 2.8;

  // Cheap viewport reject to keep GPU cost stable on mobile.
  if (abs(p.x) > 2.2 || p.y < -1.4 || p.y > 2.4) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  int target = int(clamp(uIterations, 8.0, float(MAX_ITERS)));
  // Hard cap recursion depth to avoid exponential explosion on device GPUs.
  int depthMax = int(clamp(float(target) * 0.08 + 4.0, 4.0, 8.0));
  float branchAngle = mix(0.32, 0.78, clamp((uBailout - 2.0) / 6.0, 0.0, 1.0));

  float trap = 1e9;
  float colorAcc = 0.0;

  int branchCount = 1;
  for (int i = 0; i < 8; i++) {
    if (i >= depthMax) break;
    branchCount *= 2;
  }

  const int MAX_BRANCHES = 256;
  branchCount = int(min(float(branchCount), float(MAX_BRANCHES)));
  for (int i = 0; i < MAX_BRANCHES; i++) {
    if (i >= branchCount) break;

    vec2 pos = vec2(0.0, -1.0);
    float ang = PI * 0.5;
    float len = 0.75;
    float idx = float(i);

    for (int d = 0; d < 8; d++) {
      if (d >= depthMax) break;

      vec2 dir = vec2(cos(ang), sin(ang));
      vec2 endP = pos + dir * len;
      float w = 0.03 * pow(0.73, float(d));
      float seg = sdSegment(p, pos, endP) - w;
      if (seg < trap) {
        trap = seg;
        colorAcc = float(d) / float(depthMax);
      }

      float bit = mod(idx, 2.0);
      idx = floor(idx * 0.5);
      ang += (bit < 0.5 ? -branchAngle : branchAngle);
      pos = endP;
      len *= 0.73;
    }
  }

  float edge = exp(-55.0 * abs(trap));
  if (edge < 0.01 || p.y < -1.15) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(colorAcc + 0.35 * edge + uTime * 0.00007);
  vec3 color = getPaletteColor(t, int(uColorScheme));
  color *= mix(vec3(0.35, 0.2, 0.1), vec3(0.3, 0.8, 0.35), colorAcc);
  color *= 0.75 + 0.6 * edge;

  fragColor = vec4(linearToSRGB(color), 1.0);
}
