#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uTransparentBg;
uniform float uFormula;
uniform float uExtra0;
uniform float uExtra1;
uniform float uExtra2;
uniform sampler2D uPalette;
uniform sampler2D uOrbit;

out vec4 fragColor;

vec2 fetchOrbit(int n) {
  int totalWidth = int(uIterations) * 2;
  float u0 = (float(n * 2) + 0.5) / float(max(totalWidth, 1));
  float u1 = (float(n * 2 + 1) + 0.5) / float(max(totalWidth, 1));
  vec4 px0 = texture(uOrbit, vec2(u0, 0.5));
  vec4 px1 = texture(uOrbit, vec2(u1, 0.5));
  float zr = px0.r * 8.0 - 4.0 + px0.g / 256.0 * 8.0;
  float zi = px1.r * 8.0 - 4.0 + px1.g / 256.0 * 8.0;
  return vec2(zr, zi);
}

vec3 samplePalette(float t) {
  return texture(uPalette, vec2(clamp(t, 0.0, 1.0), 0.5)).rgb;
}

vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 deltaMandelbrot(vec2 Zn, vec2 dz, vec2 dc) {
  return 2.0 * cmul(Zn, dz) + cmul(dz, dz) + dc;
}

vec2 deltaJulia(vec2 Zn, vec2 dz) {
  return 2.0 * cmul(Zn, dz) + cmul(dz, dz);
}

vec2 deltaBurningShip(vec2 Zn, vec2 dz, vec2 dc) {
  vec2 Wn = vec2(abs(Zn.x), abs(Zn.y));
  vec2 dw = vec2(sign(Zn.x) * dz.x, sign(Zn.y) * dz.y);
  return 2.0 * cmul(Wn, dw) + cmul(dw, dw) + dc;
}

vec2 deltaBuffalo(vec2 Zn, vec2 dz, vec2 dc) {
  float Zr2 = Zn.x * Zn.x - Zn.y * Zn.y;
  float Zi2 = 2.0 * Zn.x * Zn.y;
  float sr = sign(Zr2);
  float si = sign(Zi2);
  float dRe = sr * (2.0 * (Zn.x * dz.x - Zn.y * dz.y) + dz.x * dz.x - dz.y * dz.y);
  float dIm = si * (2.0 * (Zn.x * dz.y + Zn.y * dz.x) + 2.0 * dz.x * dz.y);
  return vec2(dRe, dIm) + dc;
}

vec2 deltaTricorn(vec2 Zn, vec2 dz, vec2 dc) {
  vec2 conjZ = vec2(Zn.x, -Zn.y);
  vec2 conjDz = vec2(dz.x, -dz.y);
  return 2.0 * cmul(conjZ, conjDz) + cmul(conjDz, conjDz) + dc;
}

vec2 deltaCeltic(vec2 Zn, vec2 dz, vec2 dc) {
  float Zr2 = Zn.x * Zn.x - Zn.y * Zn.y;
  float sr = sign(Zr2);
  float dRe = sr * (2.0 * (Zn.x * dz.x - Zn.y * dz.y) + dz.x * dz.x - dz.y * dz.y);
  float dIm = 2.0 * (Zn.x * dz.y + Zn.y * dz.x) + 2.0 * dz.x * dz.y;
  return vec2(dRe, dIm) + dc;
}

vec2 deltaMultibrot3(vec2 Zn, vec2 dz, vec2 dc) {
  vec2 Z2 = cmul(Zn, Zn);
  return 3.0 * cmul(Z2, dz) + 3.0 * cmul(Zn, cmul(dz, dz)) + cmul(cmul(dz, dz), dz) + dc;
}

vec2 deltaMultibrot4(vec2 Zn, vec2 dz, vec2 dc) {
  vec2 Z2 = cmul(Zn, Zn);
  vec2 Z3 = cmul(Z2, Zn);
  vec2 dz2 = cmul(dz, dz);
  return 4.0 * cmul(Z3, dz) + 6.0 * cmul(Z2, dz2) + 4.0 * cmul(Zn, cmul(dz2, dz)) + cmul(dz2, dz2) + dc;
}

vec2 deltaMultibrot5(vec2 Zn, vec2 dz, vec2 dc) {
  vec2 Z2 = cmul(Zn, Zn);
  vec2 Z4 = cmul(Z2, Z2);
  return 5.0 * cmul(Z4, dz) + dc;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  int formula = int(uFormula + 0.5);
  float bailoutSq = uBailout * uBailout;
  int maxIter = int(clamp(uIterations, 4.0, 500.0));

  vec2 dc = uv / max(1e-9, uZoom);
  vec2 dz = vec2(0.0);
  vec2 dzPrev = vec2(0.0);
  int it = 0;
  float finalMag2 = 0.0;

  const int MAX_ITERS = 500;

  for (int n = 0; n < MAX_ITERS; n++) {
    if (n >= maxIter) {
      it = maxIter;
      break;
    }

    vec2 Zn = fetchOrbit(n);
    vec2 dzNew;

    if (formula == 0) {
      dzNew = deltaMandelbrot(Zn, dz, dc);
    } else if (formula == 1) {
      dzNew = deltaJulia(Zn, dz);
    } else if (formula == 2) {
      dzNew = deltaBurningShip(Zn, dz, dc);
    } else if (formula == 3) {
      dzNew = deltaBuffalo(Zn, dz, dc);
    } else if (formula == 4) {
      dzNew = deltaTricorn(Zn, dz, dc);
    } else if (formula == 5) {
      dzNew = deltaCeltic(Zn, dz, dc);
    } else if (formula == 6) {
      dzNew = deltaMultibrot3(Zn, dz, dc);
    } else if (formula == 7) {
      dzNew = deltaMultibrot4(Zn, dz, dc);
    } else if (formula == 8) {
      dzNew = deltaMultibrot5(Zn, dz, dc);
    } else {
      float p = uExtra0;
      dzNew = 2.0 * cmul(Zn, dz) + cmul(dz, dz) + p * dzPrev + dc;
    }

    if (dot(dzNew, dzNew) > dot(Zn, Zn) * 1e6) {
      dzNew = Zn + dzNew;
    }

    dzPrev = dz;
    dz = dzNew;

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
    fragColor = (uTransparentBg > 0.5)
        ? vec4(0.0)
        : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
  float t = fract(smoothVal / max(1.0, uIterations) + uTime * 0.0001);
  fragColor = vec4(samplePalette(t), 1.0);
}
