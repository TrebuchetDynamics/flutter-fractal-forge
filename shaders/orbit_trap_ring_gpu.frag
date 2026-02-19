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
uniform float uRingRadius;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.7))
    );
  } else if (scheme == 1) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.0))
    );
  } else if (scheme == 2) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}

bool inMainBulb(vec2 c) {
  float y2 = c.y * c.y;
  float q  = (c.x - 0.25) * (c.x - 0.25) + y2;
  if (q * (q + (c.x - 0.25)) < 0.25 * y2) return true;
  if ((c.x + 1.0) * (c.x + 1.0) + y2 < 0.0625) return true;
  return false;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  float bailoutSq = uBailout * uBailout;
  float ringR = clamp(uRingRadius, 0.01, 5.0);

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));

  vec2 z = vec2(0.0);
  int it = target;

  // Ring orbit trap: minimum of ||z| - r| across orbit
  float trapMin = 1e10;
  int trapIter = 0;

  if (!inMainBulb(c)) {
    it = 0;
    for (int j = 0; j < MAX_ITERS; j++) {
      if (j >= target) { it = target; break; }
      z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

      // Ring trap: distance from orbit point to circle of radius r
      float ringDist = abs(length(z) - ringR);
      if (ringDist < trapMin) {
        trapMin = ringDist;
        trapIter = j;
      }

      if (dot(z, z) > bailoutSq) { it = j; break; }
      it = j + 1;
    }
  }

  if (it >= target) {
    if (trapMin < 1e9) {
      float t = fract(trapMin * 2.0 + float(trapIter) / 64.0 + uTime * 0.0001);
      vec3 col = palette(t, schemeInt) * 0.5;
      fragColor = vec4(linearToSRGB(col), 1.0);
    } else {
      fragColor = (uTransparentBg > 0.5)
        ? vec4(0.0)
        : vec4(0.0, 0.0, 0.0, 1.0);
    }
    return;
  }

  float t = fract(trapMin * 3.0 + float(trapIter) / 64.0 + uTime * 0.0001);
  float brightness = 1.0 - clamp(trapMin * 2.0, 0.0, 0.8);
  vec3 col = palette(t, schemeInt) * brightness;
  fragColor = vec4(linearToSRGB(col), 1.0);
}
