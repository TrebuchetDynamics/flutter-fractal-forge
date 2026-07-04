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

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.7)));
  } else if (scheme == 1) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.0)));
  } else if (scheme == 2) {
    return vec3(0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
                0.5 + 0.5 * cos(6.28318 * (t + 0.67)));
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c4 = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318 * (c4 * t + d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = dot(b,b);
  if (d < 1e-20) return vec2(1e10);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}


vec2 laguerreL(vec2 z, int n) {
  vec2 l0 = vec2(1.0, 0.0);
  if (n == 0) return l0;
  vec2 l1 = vec2(1.0, 0.0) - z;
  if (n == 1) return l1;
  vec2 ln = l1;
  for (int k = 2; k <= 10; k++) {
    if (k > n) break;
    float fk = float(k);
    ln = ((2.0 * fk - 1.0 - z.x) * l1 - vec2(z.y * l1.y, -z.y * l1.x) - (fk - 1.0) * l0) / fk;
    l0 = l1;
    l1 = ln;
  }
  return ln;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;
  vec2 z0 = z;
  int n = int(clamp(floor(2.0 + 0.3 * uBailout), 2.0, 8.0));

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)));
  int it = 0;
  float stepMag = 0.0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }
    vec2 f = laguerreL(z, n);
    vec2 fp = (laguerreL(z + vec2(1e-3, 0.0), n) - f) / 1e-3;
    vec2 step = cdiv(f, fp);
    z -= step;
    stepMag = dot(step, step);

    if (stepMag < 1e-10) { it = j; break; }
    if (dot(z,z) > 256.0) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float contour = 0.18 * sin(11.0 * z0.x + 5.0 * z0.y) +
      0.12 * cos(17.0 * length(z0));
  float t = fract(float(it) / max(1.0, uIterations) +
      0.3 * exp(-60.0 * stepMag) + contour + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(palette(t, int(uColorScheme))), 1.0);
}
