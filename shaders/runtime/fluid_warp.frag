#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uTime;
uniform float uStrength;
uniform float uTouchX;
uniform float uTouchY;
uniform float uTouchDown;
uniform float uTouchEnergy;
uniform float uTouchVelocityX;
uniform float uTouchVelocityY;
uniform float uSecondaryTouchX;
uniform float uSecondaryTouchY;
uniform float uSecondaryTouchDown;

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

vec2 touchSplat(vec2 d, vec2 velocity, float energy) {
  float r2 = dot(d, d);
  float core = exp(-r2 * 52.0);
  float wake = exp(-r2 * 15.0);
  vec2 vortex = vec2(-d.y, d.x) * (core * 0.14 + wake * 0.05);
  return (vortex + velocity * wake * 0.75) * energy;
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
  // Two flow scales keep the motion legible instead of looking like a single
  // repeating noise texture.
  vec2 v = curl(p * 3.4 + vec2(t * 0.18, -t * 0.13));
  v = mix(v, curl(p * 6.2 - vec2(t * 0.11, t * 0.08)), 0.32);

  vec2 touch = vec2(uTouchX, uTouchY);
#ifdef IMPELLER_TARGET_OPENGLES
  touch.y = 1.0 - touch.y;
#endif
  vec2 d = (uv - touch) * aspect;
  float energy = clamp(max(uTouchDown, uTouchEnergy), 0.0, 1.0);
  vec2 touchVelocity = vec2(uTouchVelocityX, uTouchVelocityY) * aspect;
#ifdef IMPELLER_TARGET_OPENGLES
  touchVelocity.y = -touchVelocity.y;
#endif

  // A velocity-aware splat gives each drag a directional wake. The energy
  // tail continues briefly after release, which makes the mode feel fluid
  // without requiring persistent ping-pong textures in an ImageFilter.
  vec2 splat = touchSplat(d, touchVelocity, energy);

  // A second finger behaves like another live layer/source instead of
  // replacing the first one.
  vec2 secondaryTouch = vec2(uSecondaryTouchX, uSecondaryTouchY);
#ifdef IMPELLER_TARGET_OPENGLES
  secondaryTouch.y = 1.0 - secondaryTouch.y;
#endif
  vec2 secondaryD = (uv - secondaryTouch) * aspect;
  splat += touchSplat(
      secondaryD, vec2(0.0), energy * uSecondaryTouchDown);

  float strength = clamp(uStrength, 0.0, 2.0);
  float warpAmount = 0.045 + sin(t * 0.7) * 0.012;
  vec2 flow = v * warpAmount + splat;
  vec2 warped = uv - flow * strength;
#ifdef IMPELLER_TARGET_OPENGLES
  warped.y = 1.0 - warped.y;
#endif

  // A restrained RGB split makes the wake read as liquid glass instead of a
  // plain blur. Keep it tied to the wake so untouched areas stay unchanged.
  vec2 prismDirection = normalize(flow + vec2(0.0001));
  float dispersion = (0.0005 + energy * 0.0035) * strength;
  vec2 prism = prismDirection * dispersion;
  vec2 sampleUV = clamp(warped, vec2(0.0), vec2(1.0));
  vec4 center = texture(uTexture, sampleUV);
  vec4 red = texture(uTexture, clamp(sampleUV + prism, vec2(0.0), vec2(1.0)));
  vec4 blue = texture(uTexture, clamp(sampleUV - prism, vec2(0.0), vec2(1.0)));
  vec4 dispersed = vec4(red.r, center.g, blue.b, center.a);

  // One extra advected sample gives the current frame a feedback-like echo
  // without allocating a persistent framebuffer on every platform.
  vec2 echoUV = clamp(sampleUV - flow * (0.12 + energy * 0.16) * strength,
      vec2(0.0), vec2(1.0));
  vec4 echo = texture(uTexture, echoUV);
  float echoMix = clamp((0.08 + energy * 0.12) * strength, 0.0, 0.35);
  vec4 fluidColor = mix(dispersed, echo, echoMix);

  // Fraksl-style filter treatment: increase color separation and contrast
  // only while Fluid mode is doing work, leaving intensity 0 truly neutral.
  float filterAmount = clamp((0.10 + energy * 0.25) * strength, 0.0, 0.75);
  float luminance = dot(fluidColor.rgb, vec3(0.2126, 0.7152, 0.0722));
  vec3 filtered = mix(vec3(luminance), fluidColor.rgb, 1.0 + filterAmount);
  filtered = (filtered - 0.5) * (1.0 + filterAmount * 0.35) + 0.5;
  fragColor = vec4(clamp(filtered, vec3(0.0), vec3(1.0)), fluidColor.a);
}
