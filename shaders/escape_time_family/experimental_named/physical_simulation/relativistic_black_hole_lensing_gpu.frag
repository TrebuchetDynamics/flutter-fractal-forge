#include <flutter/runtime_effect.glsl>

precision highp float;

// Original, stateless approximation of gravitational lensing around a
// rotating compact object. This is not copied from a ShaderToy implementation.
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;
uniform float uMass;
uniform float uSpin;
uniform float uDiskTilt;

out vec4 fragColor;

const float TAU = 6.283185307179586;

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

vec3 palette(float heat, float scheme) {
  float shift = fract(scheme * 0.137);
  vec3 warm = mix(vec3(0.55, 0.035, 0.008), vec3(1.0, 0.86, 0.48), heat);
  vec3 alternate = 0.48 + 0.52 * cos(TAU * (heat + shift + vec3(0.0, 0.31, 0.67)));
  return mix(warm, alternate, step(1.5, mod(scheme, 4.0)) * 0.32);
}

float starField(vec2 p) {
  vec2 cell = floor(p * 42.0);
  vec2 local = fract(p * 42.0) - 0.5;
  float seed = hash21(cell);
  float star = smoothstep(0.035, 0.0, length(local)) * step(0.965, seed);
  return star * mix(0.35, 1.35, seed);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float shortSide = max(1.0, min(uResolution.x, uResolution.y));
  vec2 p = (fragCoord - 0.5 * uResolution) / shortSide;
  p = p / max(uZoom, 0.0001) + uCenter;

  float mass = clamp(uMass, 0.6, 1.8);
  float spin = clamp(uSpin, -1.0, 1.0);
  float radius = length(p);
  float angle = atan(p.y, p.x);
  float horizon = 0.105 * mass;
  float photonRadius = horizon * 1.54;

  // Bend background rays azimuthally and radially. The bounded denominator
  // creates an Einstein ring without singular arithmetic at the horizon.
  float bend = 0.075 * mass / max(radius, horizon * 0.72);
  float frameDrag = spin * 0.18 * exp(-7.0 * radius);
  vec2 lensed = vec2(cos(angle + frameDrag), sin(angle + frameDrag)) *
      (radius + bend);
  float stars = starField(lensed + vec2(0.018 * uTime, 0.0));
  stars += 0.45 * starField(lensed * 1.73 - vec2(0.0, 0.011 * uTime));

  float ring = exp(-pow((radius - photonRadius) / (0.009 + 0.004 * mass), 2.0));

  // A tilted projected disk plus its upper lensed image. Radial bands and
  // orbital phase provide fine structure; spin controls Doppler asymmetry.
  vec2 diskPoint = vec2(p.x, p.y / max(0.12, uDiskTilt));
  float diskRadius = length(diskPoint);
  float diskMask = smoothstep(horizon * 1.25, horizon * 1.75, diskRadius) *
      (1.0 - smoothstep(0.49, 0.64, diskRadius));
  float diskAngle = atan(diskPoint.y, diskPoint.x);
  float bands = 0.58 + 0.42 * sin(105.0 * diskRadius - 2.4 * uTime + 3.0 * diskAngle);
  float turbulence = 0.76 + 0.24 * sin(37.0 * diskRadius + 7.0 * diskAngle + uTime);
  float doppler = clamp(1.0 + 0.72 * spin * cos(diskAngle), 0.22, 1.8);
  float disk = diskMask * (0.58 + 0.42 * bands) * turbulence * doppler;

  float upperArc = exp(-pow((radius - photonRadius * 1.18) / 0.025, 2.0)) *
      smoothstep(-0.015, 0.09, p.y) * smoothstep(0.30, 0.0, abs(p.x));
  float heat = clamp(1.2 - diskRadius / 0.62, 0.0, 1.0);
  vec3 color = vec3(stars * vec3(0.62, 0.76, 1.0));
  color += palette(heat, uColorScheme) * (1.45 * disk + 0.85 * upperArc);
  color += vec3(1.0, 0.72, 0.34) * 1.8 * ring;

  float shadow = 1.0 - smoothstep(horizon * 0.90, horizon * 1.03, radius);
  color *= 1.0 - shadow;
  color = 1.0 - exp(-color);
  float alpha = uTransparentBg > 0.5 ? clamp(max(max(color.r, color.g), color.b) * 1.4, 0.0, 1.0) : 1.0;
  fragColor = vec4(color, alpha);
}
