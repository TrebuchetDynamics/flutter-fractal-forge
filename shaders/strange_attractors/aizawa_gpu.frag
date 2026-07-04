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
out vec4 fragColor;

const float PI = 3.14159265359;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) { return a + b * cos(6.28318 * (c * t + d)); }
vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.00, 0.33, 0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.50, 0.30, 0.00));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0, 0.7, 0.4), vec3(0.00, 0.15, 0.20));
  if (scheme == 3) { float g = 0.5 + 0.5 * cos(6.28318 * t); return vec3(g); }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0 + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec3 aizawaDeriv(vec3 p, float a, float b, float c, float d, float e, float f) {
  float x = p.x;
  float y = p.y;
  float z = p.z;
  float x2 = x * x;
  float y2 = y * y;
  
  float dx = (z - b) * x - d * y;
  float dy = d * x + (z - b) * y;
  float dz = c + a * z - (z * z * z) / 3.0 - (x2 + y2) * (1.0 + e * z) + f * z * x2 * x;
  
  return vec3(dx, dy, dz);
}

vec3 rk4Step(vec3 p, float dt, float a, float b, float c, float d, float e, float f) {
  vec3 k1 = aizawaDeriv(p, a, b, c, d, e, f);
  vec3 k2 = aizawaDeriv(p + 0.5 * dt * k1, a, b, c, d, e, f);
  vec3 k3 = aizawaDeriv(p + 0.5 * dt * k2, a, b, c, d, e, f);
  vec3 k4 = aizawaDeriv(p + dt * k3, a, b, c, d, e, f);
  return p + (dt / 6.0) * (k1 + 2.0 * k2 + 2.0 * k3 + k4);
}

vec3 project3Dto2D(vec3 p, float angle) {
  float cosA = cos(angle);
  float sinA = sin(angle);
  float projX = p.x * cosA - p.z * sinA;
  float projY = p.y;
  return vec3(projX, projY, p.z);
}

float hash21(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float aspect = uResolution.x / uResolution.y;
  vec2 uv = (fragCoord - 0.5 * uResolution) / min(uResolution.x, uResolution.y);
  
  float a = 0.95;
  float b = 0.7;
  float c = 0.6;
  float d = 3.5;
  float e = 0.25;
  float f = 0.1;
  float dt = 0.008;
  
  float angle = 0.3 + 0.15 * sin(uTime * 0.0003);
  
  int iters = int(clamp(uIterations, 10.0, 48.0));
  
  float density = 0.0;
  float totalWeight = 0.0;
  
  // ponytail: per-pixel RK4 is the ceiling here; 6 short orbits keep the catalog renderer usable.
  for (int seed = 0; seed < 6; seed++) {
    float seedF = float(seed) / 6.0;
    
    float theta = hash21(vec2(seedF, 0.0)) * 2.0 * PI;
    float phi = hash21(vec2(seedF, 1.0)) * PI;
    float r = 0.3 + 0.4 * hash21(vec2(seedF, 2.0));
    
    vec3 p = vec3(
      r * sin(phi) * cos(theta),
      r * sin(phi) * sin(theta),
      r * cos(phi) * 0.5
    );
    
    float orbitWeight = 1.0;
    
    for (int i = 0; i < 64; i++) {
      if (i >= iters) break;
      
      p = rk4Step(p, dt, a, b, c, d, e, f);
      
      vec3 proj = project3Dto2D(p, angle);
      vec2 screenPos = (proj.xy - uCenter) * uZoom;
      
      float dist = length(uv - screenPos);
      float influence = exp(-dist * dist * 800.0) * orbitWeight;
      
      float t = float(i) / float(iters);
      float phase = float(seed) / 6.0 + t * 0.5 + uTime * 0.00005;
      density += influence * getPaletteColor(phase, int(uColorScheme)).r;
      totalWeight += influence;
      
      orbitWeight *= 0.995;
    }
  }
  
  density = density / max(0.001, totalWeight);
  
  vec3 col = getPaletteColor(density * 3.0 + uTime * 0.0001, int(uColorScheme));
  
  col = pow(col, vec3(0.8));
  col *= 1.25 + 0.12 * sin(19.0 * uv.x + 23.0 * uv.y);
  
  fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.95 : 1.0);
}