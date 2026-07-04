#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;           // 0
uniform vec2  uResolution;     // 1-2
uniform vec2  uCenter;         // 3-4
uniform float uZoom;           // 5
uniform float uIterations;     // 6
uniform float uBailout;        // 7
uniform float uColorScheme;    // 8
uniform float uTransparentBg;  // 9

// Palette as a 256x1 texture sampler (index 0)
uniform sampler2D uPalette;

out vec4 fragColor;

bool inMainBulb(vec2 c) {
  float y2 = c.y * c.y;
  float q = (c.x - 0.25) * (c.x - 0.25) + y2;
  if (q * (q + (c.x - 0.25)) < 0.25 * y2) return true;
  if ((c.x + 1.0) * (c.x + 1.0) + y2 < 0.0625) return true;
  return false;
}

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  vec2 z = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  const int MAX_ITERS = 320;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  bool skipIter = inMainBulb(c);
  if (skipIter) {
    it = target;
  } else {
    for (int j = 0; j < MAX_ITERS; j++) {
      if (j >= target) { it = target; break; }
      z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
      if (dot(z, z) > bailoutSq) { it = j; break; }
      it = j + 1;
    }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Smooth iteration count
  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));
  float t = fract(smoothVal / 64.0);
  t = fract(t + uTime * 0.0001 + uColorScheme * 0.000001);

  // Sample palette texture
  vec2 palUV = vec2(clamp(t, 0.0, 1.0), 0.5);
  vec3 col = texture(uPalette, palUV).rgb;
  fragColor = vec4(linearToSRGB(col), 1.0);
}
