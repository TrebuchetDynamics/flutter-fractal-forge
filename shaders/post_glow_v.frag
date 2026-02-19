#include <flutter/runtime_effect.glsl>

precision highp float;

// Vertical separable Gaussian glow pass + composite.
//
// Pass 2 of a 2-pass glow effect.
// Takes the horizontally-blurred result (uBlur) and composites it
// over the original fractal frame (uFrame) using additive blending.
//
// Uniforms:
//   sampler2D uFrame    - original fractal frame (pre-blur)
//   sampler2D uBlur     - horizontal blur output from post_glow_h.frag
//   uResolution (vec2)  - viewport size in pixels
//   uRadius     (float) - blur radius multiplier
//   uIntensity  (float) - glow brightness [0.0 – 1.0], default 0.35

uniform sampler2D uFrame;     // sampler 0 – original frame
uniform sampler2D uBlur;      // sampler 1 – horizontally blurred frame
uniform vec2  uResolution;    // float 0-1
uniform float uRadius;        // float 2
uniform float uIntensity;     // float 3  (0.35 feels subtle but visible)

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

const int TAPS = 7;
const float kWeights[7] = float[7](
  0.2270270270,
  0.1945945946,
  0.1216216216,
  0.0540540541,
  0.0162162162,
  0.0030030030,
  0.0006000600
);

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uResolution, vec2(1.0));

  float stepY = uRadius / max(uResolution.y, 1.0);

  // Vertical blur of the already-horizontally-blurred input.
  vec4 glow = texture(uBlur, uv) * kWeights[0];
  for (int i = 1; i < TAPS; i++) {
    float offset = float(i) * stepY;
    glow += texture(uBlur, vec2(uv.x, uv.y + offset)) * kWeights[i];
    glow += texture(uBlur, vec2(uv.x, uv.y - offset)) * kWeights[i];
  }

  // Original sharp frame.
  vec4 original = texture(uFrame, uv);

  // Additive composite: glow lifts bright areas without darkening darks.
  vec4 composited = original + glow * uIntensity;
  composited.a = original.a;

  fragColor = clamp(composited, 0.0, 1.0);
}
