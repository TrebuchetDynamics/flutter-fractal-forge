#include <flutter/runtime_effect.glsl>

precision highp float;

// Horizontal separable Gaussian glow pass.
//
// Pass 1 of a 2-pass glow effect:
//   post_glow_h.frag  → horizontal blur of the source fractal frame
//   post_glow_v.frag  → vertical blur of the horizontal result + composite
//
// Uniforms:
//   sampler2D uFrame    - source fractal image (set via FragmentShader.setImageSampler)
//   uResolution (vec2)  - viewport size in pixels
//   uRadius     (float) - blur radius multiplier (1.0 = standard glow width)

uniform sampler2D uFrame;     // sampler index 0
uniform vec2  uResolution;    // float 0-1
uniform float uRadius;        // float 2  (1.0 = ~12px glow at 1080p)

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// 13-tap Gaussian kernel (σ ≈ 3.0).
// Weights are symmetric; we use 7 unique values (centre + 6 pairs).
const int TAPS = 7;
float gaussianWeight(int index) {
  if (index == 0) return 0.2270270270;
  if (index == 1) return 0.1945945946;
  if (index == 2) return 0.1216216216;
  if (index == 3) return 0.0540540541;
  if (index == 4) return 0.0162162162;
  if (index == 5) return 0.0030030030;
  return 0.0006000600;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uResolution, vec2(1.0));

  float stepX = uRadius / max(uResolution.x, 1.0);

  vec4 result = texture(uFrame, uv) * gaussianWeight(0);
  for (int i = 1; i < TAPS; i++) {
    float offset = float(i) * stepX;
    float weight = gaussianWeight(i);
    result += texture(uFrame, vec2(uv.x + offset, uv.y)) * weight;
    result += texture(uFrame, vec2(uv.x - offset, uv.y)) * weight;
  }

  fragColor = result;
}
