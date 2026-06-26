#include <flutter/runtime_effect.glsl>

precision highp float;

// Klausmeier banded vegetation model, rendered as a static explicit iteration.
// Plant biomass u and water w follow a reaction-diffusion-advection system:
//   du/dt = u^2 w - B u + D_u ∇²u
//   dw/dt = A - w - u^2 w + D_w ∇²w - v ∂w/∂x

uniform float uTime;             // 0
uniform vec2  uResolution;       // 1-2
uniform vec2  uCenter;           // 3-4
uniform float uZoom;             // 5
uniform float uIterations;       // 6
uniform float uBailout;          // 7
uniform float uColorScheme;      // 8
uniform float uTransparentBg;    // 9
uniform float uRainfall;         // 10 A
uniform float uMortality;        // 11 B
uniform float uWaterDiffusion;   // 12 D_w
uniform float uPlantDiffusion;   // 13 D_u
uniform float uAdvection;        // 14 v

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float terrain(vec2 p) {
  return 0.5 + 0.5 * sin(9.0 * p.x + 2.2 * sin(5.0 * p.y));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(uZoom, 1e-6) + uCenter;

  float rainfall = clamp(uRainfall, 0.1, 5.0);
  float mortality = clamp(uMortality, 0.05, 2.0);
  float waterDiffusion = clamp(uWaterDiffusion, 0.0, 20.0);
  float plantDiffusion = clamp(uPlantDiffusion, 0.0, 5.0);
  float advection = clamp(uAdvection, 0.0, 2.0);

  float u = 0.18 + 0.08 * hash12(floor(p * 80.0));
  float w = rainfall + 0.15 * terrain(p * 1.7);
  float dt = 0.018;
  int steps = int(clamp(uIterations, 1.0, 96.0));

  for (int i = 0; i < 96; i++) {
    if (i >= steps) break;
    float t = terrain(p + float(i) * vec2(0.018, 0.006));
    float lapU = (t - 0.5) - 0.35 * u;
    float lapW = (0.5 - t) - 0.12 * w;
    float gradW = cos(9.0 * p.x + float(i) * 0.08);
    float growth = u * u * w;

    u += dt * (growth - mortality * u + plantDiffusion * lapU);
    w += dt * (rainfall - w - growth + waterDiffusion * lapW - advection * gradW);
    u = clamp(u, 0.0, 4.0);
    w = clamp(w, 0.0, 8.0);
  }

  float biomass = smoothstep(0.05, 1.4, u);
  vec3 dry = vec3(0.42, 0.30, 0.16);
  vec3 grass = vec3(0.08, 0.42, 0.13);
  vec3 lush = vec3(0.35, 0.75, 0.24);
  vec3 color = mix(dry, mix(grass, lush, smoothstep(0.7, 1.8, u)), biomass);
  color += 0.12 * smoothstep(0.0, rainfall, w) * vec3(0.05, 0.10, 0.18);

  if (biomass < 0.01 && uTransparentBg > 0.5) {
    fragColor = vec4(0.0);
    return;
  }
  fragColor = vec4(linearToSRGB(color), 1.0);
}
