#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uTransparentBg;
uniform sampler2D uPalette;   // sampler 0: 256x1 palette
uniform sampler2D uOrbit;     // sampler 1: (maxIter*2)x1, each pixel = 1 float (hi16/lo16)

out vec4 fragColor;

// -------------------------------------------------------------------
// Orbit fetch: each complex Z_n is stored as two consecutive float32
// values encoded as normalized [0,1] pairs in RG channels.
// Encoding (CPU): store (zr, zi) directly as two floats; the orbit
// texture is built as a float-normalized RG texture via picture recorder.
//
// Impeller-safe approach: store zr and zi as separate pixels in RG16F
// emulation. Since we can't use uintBitsToFloat in Impeller, we instead
// store orbit values directly as float-normalized values using two pixels
// per orbit step, with each float split into integer part (R channel)
// and fractional part (G channel) scaled to avoid precision loss.
//
// Simpler approach that Impeller supports: store as RGBA with
// zr in R+G (hi byte / lo byte as 0..1), zi in B+A.
// Decode: val = R_raw * 256.0 + G_raw - 128.0 for integer part, etc.
//
// ACTUALLY simplest Impeller-safe approach: encode each float as
// two channels: R = floor(v * 1000 + 128) / 255  G = fract(v * 1000)
// This gives 3 decimal digits precision in a [-128,128] range.
// For orbit values within [-2, 2] this is fine.
//
// We use: pixel R = (v + 4.0) / 8.0  (maps [-4,4] → [0,1] in R)
//         pixel G = fract((v + 4.0) / 8.0 * 256.0) / 1.0  (sub-pixel)
// Decode: v = R_raw * 8.0 - 4.0 + G_raw * 8.0 / 256.0
// Precision: 8/256 ≈ 0.031 — sufficient for float32 orbit values
// (orbit values are within bailout radius ≤ 8.0)
// -------------------------------------------------------------------
vec2 fetchOrbit(int n) {
  int totalWidth = int(uIterations) * 2;
  float u0 = (float(n * 2)     + 0.5) / float(max(totalWidth, 1));
  float u1 = (float(n * 2 + 1) + 0.5) / float(max(totalWidth, 1));
  vec4 px0 = texture(uOrbit, vec2(u0, 0.5));
  vec4 px1 = texture(uOrbit, vec2(u1, 0.5));
  // Decode: R = coarse (mapped [−4,4]→[0,1]), G = fine fraction
  float zr = px0.r * 8.0 - 4.0 + px0.g / 256.0 * 8.0;
  float zi = px1.r * 8.0 - 4.0 + px1.g / 256.0 * 8.0;
  return vec2(zr, zi);
}

vec3 samplePalette(float t) {
  return texture(uPalette, vec2(clamp(t, 0.0, 1.0), 0.5)).rgb;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  // dc: pixel offset from reference point in fractal space
  vec2 dc = uv / max(1e-9, uZoom);

  float bailoutSq = uBailout * uBailout;
  int maxIter = int(clamp(uIterations, 4.0, 500.0));

  vec2 dz = vec2(0.0);
  int it = 0;
  float finalMag2 = 0.0;

  // Impeller requires constant loop bound — use 500 (matches shader max)
  const int MAX_ITERS = 500;

  for (int n = 0; n < MAX_ITERS; n++) {
    if (n >= maxIter) {
      it = maxIter;
      break;
    }

    vec2 Zn = fetchOrbit(n);

    // dz_{n+1} = 2·Zn·dz + dz² + dc
    vec2 ZnDz = vec2(Zn.x * dz.x - Zn.y * dz.y,
                     Zn.x * dz.y + Zn.y * dz.x);
    vec2 dz2  = vec2(dz.x * dz.x - dz.y * dz.y,
                     2.0 * dz.x * dz.y);
    dz = 2.0 * ZnDz + dz2 + dc;

    // Glitch detection: rebase when |dz| >> |Zn|
    if (dot(dz, dz) > dot(Zn, Zn) * 1e6) {
      dz = Zn + dz;
    }

    // Escape check on full orbit value
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

  // Smooth coloring
  float smoothVal = float(it) - log2(log2(max(1e-12, finalMag2))) + 4.0;
  float t = fract(smoothVal / max(1.0, uIterations) + uTime * 0.0001);
  fragColor = vec4(samplePalette(t), 1.0);
}
