#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uTransparentBg;
uniform sampler2D uPalette;
uniform sampler2D uOrbit;

out vec4 fragColor;

float decodeFloat(vec4 v) {
  uvec4 b = uvec4(v * 255.0 + 0.5);
  uint bits = b.r | (b.g << 8u) | (b.b << 16u) | (b.a << 24u);
  return uintBitsToFloat(bits);
}

vec2 fetchOrbit(int n) {
  int totalWidth = int(uIterations) * 2;
  float u0 = (float(n * 2) + 0.5) / float(totalWidth);
  float u1 = (float(n * 2 + 1) + 0.5) / float(totalWidth);
  float zr = decodeFloat(texture(uOrbit, vec2(u0, 0.5)));
  float zi = decodeFloat(texture(uOrbit, vec2(u1, 0.5)));
  return vec2(zr, zi);
}

vec3 samplePalette(float t) {
  return texture(uPalette, vec2(clamp(t, 0.0, 1.0), 0.5)).rgb;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 dc = uv / max(0.000001, uZoom);

  float bailoutSq = uBailout * uBailout;
  int maxIter = int(clamp(uIterations, 0.0, 5000.0));

  vec2 dz = vec2(0.0);
  int it = 0;
  float finalMag2 = 0.0;

  const int MAX_ITERS = 5000;

  for (int n = 0; n < MAX_ITERS; n++) {
    if (n >= maxIter) {
      it = maxIter;
      break;
    }

    vec2 Zn = fetchOrbit(n);

    vec2 dz2 = vec2(dz.x * dz.x - dz.y * dz.y, 2.0 * dz.x * dz.y);
    vec2 ZnDz = vec2(Zn.x * dz.x - Zn.y * dz.y, Zn.x * dz.y + Zn.y * dz.x);
    dz = 2.0 * ZnDz + dz2 + dc;

    float dzMag2 = dot(dz, dz);
    float ZnMag2 = dot(Zn, Zn);
    if (dzMag2 > ZnMag2 * 1e6) {
      dz = Zn + dz;
    }

    vec2 fullZ = Zn + dz;
    float mag2 = dot(fullZ, fullZ);
    if (mag2 > bailoutSq) {
      it = n;
      finalMag2 = mag2;
      break;
    }

    it = n + 1;
  }

  if (it >= maxIter) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
  float t = fract(smoothVal / max(1.0, uIterations) + uTime * 0.0001);
  vec3 col = samplePalette(t);
  fragColor = vec4(col, 1.0);
}
