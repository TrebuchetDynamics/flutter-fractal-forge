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
uniform float uFriction;

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

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 startPos = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  float friction = clamp(uFriction, 0.01, 1.0);

  // 3 magnets at 120 degree intervals, radius 1
  vec2 m0 = vec2(1.0, 0.0);
  vec2 m1 = vec2(-0.5, 0.866025);
  vec2 m2 = vec2(-0.5, -0.866025);

  // Simulate the damped pendulum from start position
  vec2 pos = startPos;
  vec2 vel = vec2(0.0);
  float dt = 0.01;
  float gravity = 0.5;
  float magnetStrength = 1.0;

  // ponytail: 5000 integration steps per pixel is overkill for catalog rendering.
  int maxSteps = int(clamp(uIterations * 3.0, 80.0, 700.0));
  int capturedBy = -1;
  float settleTime = float(maxSteps);
  float captureThreshold = 0.05;

  for (int i = 0; i < 700; i++) {
    if (i >= maxSteps) break;

    // Force from each magnet: F_i = strength * (m_i - pos) / |m_i - pos|^3
    vec2 force = vec2(0.0);

    vec2 d0 = m0 - pos;
    float r0 = length(d0);
    r0 = max(r0, 0.01);
    force += magnetStrength * d0 / (r0 * r0 * r0);

    vec2 d1 = m1 - pos;
    float r1 = length(d1);
    r1 = max(r1, 0.01);
    force += magnetStrength * d1 / (r1 * r1 * r1);

    vec2 d2 = m2 - pos;
    float r2 = length(d2);
    r2 = max(r2, 0.01);
    force += magnetStrength * d2 / (r2 * r2 * r2);

    // Gravity: restoring force toward center
    force -= gravity * pos;

    // Friction: damping
    force -= friction * vel;

    // Integrate (velocity Verlet simplified)
    vel += force * dt;
    pos += vel * dt;

    // Check capture
    float dist0 = length(pos - m0);
    float dist1 = length(pos - m1);
    float dist2 = length(pos - m2);

    if (dist0 < captureThreshold && length(vel) < 0.1) {
      capturedBy = 0;
      settleTime = float(i);
      break;
    }
    if (dist1 < captureThreshold && length(vel) < 0.1) {
      capturedBy = 1;
      settleTime = float(i);
      break;
    }
    if (dist2 < captureThreshold && length(vel) < 0.1) {
      capturedBy = 2;
      settleTime = float(i);
      break;
    }
  }

  // If not captured, find nearest magnet
  if (capturedBy < 0) {
    float dist0 = length(pos - m0);
    float dist1 = length(pos - m1);
    float dist2 = length(pos - m2);
    if (dist0 < dist1 && dist0 < dist2) capturedBy = 0;
    else if (dist1 < dist2) capturedBy = 1;
    else capturedBy = 2;
  }

  // Color by magnet + settle time
  float timeNorm = settleTime / float(maxSteps);
  float brightness = 1.0 - 0.7 * timeNorm;

  // Base hue offset per magnet
  float hueOffset = float(capturedBy) * 0.333;
  float t = fract(hueOffset + timeNorm * 0.5 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt) * brightness;
  col *= 0.85 + 0.15 * sin(18.0 * length(startPos) + settleTime * 0.03);

  fragColor = vec4(linearToSRGB(col), 1.0);
}
