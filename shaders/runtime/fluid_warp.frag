#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uTime;
uniform float uStrength;
uniform float uTouchX;
uniform float uTouchY;
uniform float uTouchDown;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(127.1, 311.7));
  p += dot(p, p + 34.23);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p = mat2(1.62, -1.18, 1.18, 1.62) * p + vec2(2.7, 5.1);
    a *= 0.52;
  }
  return v;
}

vec2 curl(vec2 p) {
  float e = 0.035;
  float nT = fbm(p + vec2(0.0, e));
  float nB = fbm(p - vec2(0.0, e));
  float nR = fbm(p + vec2(e, 0.0));
  float nL = fbm(p - vec2(e, 0.0));
  return vec2(nT - nB, nL - nR) / (2.0 * e);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uSize, vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif

  float t = uTime * 0.001;
  vec2 aspect = vec2(uSize.x / max(uSize.y, 1.0), 1.0);
  vec2 p = (uv - 0.5) * aspect;
  vec2 v = curl(p * 3.4 + vec2(t * 0.18, -t * 0.13));

  vec2 touch = vec2(uTouchX, uTouchY);
#ifdef IMPELLER_TARGET_OPENGLES
  touch.y = 1.0 - touch.y;
#endif
  vec2 d = (uv - touch) * aspect;
  float r2 = dot(d, d);
  vec2 swirl = vec2(-d.y, d.x) * exp(-r2 * 42.0) * uTouchDown;

  // ponytail: stateless curl-noise warp; real fluids need ping-pong dye/velocity textures.
  float warpAmount = 0.04 + sin(t * 0.7) * 0.01;
  vec2 warped = uv - (v * warpAmount + swirl * 0.12) * clamp(uStrength, 0.0, 2.0);
#ifdef IMPELLER_TARGET_OPENGLES
  warped.y = 1.0 - warped.y;
#endif
  fragColor = texture(uTexture, clamp(warped, vec2(0.0), vec2(1.0)));
}
