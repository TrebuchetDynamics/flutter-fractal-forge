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
uniform float uCellScale;
uniform float uJitter;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(269.5, 183.3)), dot(p, vec2(113.5, 271.9)))) * 43758.5453);
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.50);
  vec3 b = vec3(0.50);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 2.0) { a = vec3(0.08, 0.15, 0.25); b = vec3(0.30, 0.42, 0.48); d = vec3(0.12, 0.36, 0.62); }
  else if (s < 5.0) { a = vec3(0.24, 0.12, 0.06); b = vec3(0.50, 0.24, 0.10); c = vec3(1.0, 0.7, 0.35); d = vec3(0.0, 0.15, 0.31); }
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 voronoi(vec2 p, float jitter) {
  vec2 cell = floor(p);
  vec2 f = fract(p);
  float d1 = 8.0;
  float d2 = 8.0;
  float id = 0.0;

  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 g = vec2(float(x), float(y));
      vec2 o = hash2(cell + g) - 0.5;
      o += 0.18 * vec2(sin(uTime * 0.0002 + hash(cell + g) * 6.28318),
                        cos(uTime * 0.00017 + hash(cell + g + 4.7) * 6.28318));
      vec2 r = g + 0.5 + o * jitter - f;
      float d = dot(r, r);
      if (d < d1) {
        d2 = d1;
        d1 = d;
        id = hash(cell + g);
      } else if (d < d2) {
        d2 = d;
      }
    }
  }
  return vec3(sqrt(d1), sqrt(d2), id);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = uResolution.x < uResolution.y ? uResolution.x : uResolution.y;
  scalePix = scalePix < 1.0 ? 1.0 : scalePix;
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 3.0 / max(uZoom, 0.0001) + uCenter;

  int levels = int(clamp(uIterations / 12.0, 3.0, 8.0));
  float cellScale = clamp(uCellScale, 1.5, 8.0);
  float jitter = clamp(uJitter, 0.1, 1.2);
  float edge = 0.0;
  float fill = 0.0;
  float idMix = 0.0;
  float amp = 1.0;
  vec2 q = p * cellScale;

  for (int i = 0; i < 8; i++) {
    if (i >= levels) break;
    vec3 v = voronoi(q, jitter);
    float crack = v.y - v.x;
    edge += amp * exp(-crack * 30.0);
    fill += amp * v.x;
    idMix += amp * v.z;
    q = q * 2.15 + vec2(v.z * 5.1, v.z * 2.7);
    amp *= 0.58;
  }

  float glass = smoothstep(0.0, 1.2, fill);
  float crackle = 1.0 - exp(-edge * 0.9);
  vec3 base = palette(fract(idMix * 0.19 + glass * 0.37), uColorScheme);
  vec3 color = base * (0.38 + 0.55 * glass);
  color = mix(color, vec3(0.93, 0.88, 0.72), crackle * 0.75);
  color += vec3(0.5, 0.7, 1.0) * pow(crackle, 3.0) * 0.25;

  float alpha = uTransparentBg > 0.5 ? max(0.18, crackle) : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
