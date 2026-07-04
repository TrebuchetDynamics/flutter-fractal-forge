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
uniform float uBranchAngle;
uniform float uCanopy;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float hash(vec2 p) {
  p = fract(p * vec2(127.1, 311.7));
  p += dot(p, p + 19.19);
  return fract(p.x * p.y);
}

float segDist(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
  return length(pa - ba * h);
}

vec2 rot(vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

vec3 leafPalette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 stem = vec3(0.26, 0.16, 0.07);
  vec3 leafA = vec3(0.08, 0.34, 0.11);
  vec3 leafB = vec3(0.36, 0.72, 0.18);
  if (s > 2.5 && s < 5.5) {
    stem = vec3(0.20, 0.11, 0.08);
    leafA = vec3(0.35, 0.12, 0.05);
    leafB = vec3(0.90, 0.48, 0.13);
  } else if (s >= 5.5) {
    stem = vec3(0.14, 0.13, 0.24);
    leafA = vec3(0.12, 0.28, 0.42);
    leafB = vec3(0.56, 0.80, 0.86);
  }
  return mix(leafA, leafB, t) + stem * (1.0 - t) * 0.25;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p0 = uv * 3.0 / max(uZoom, 0.0001) + uCenter + vec2(0.0, -0.55);

  vec2 p = p0;
  float d = segDist(p, vec2(0.0, -0.95), vec2(0.0, 0.0));
  float depthHit = 0.0;
  float scaleAccum = 1.0;
  float angle = clamp(uBranchAngle, 0.25, 1.15);
  float spread = clamp(uCanopy, 0.25, 1.4);
  int levels = int(clamp(uIterations / 12.0, 4.0, 10.0));

  for (int i = 0; i < 10; i++) {
    if (i >= levels) break;
    float side = p.x < 0.0 ? -1.0 : 1.0;
    float branchLean = side * (angle + 0.09 * sin(uTime * 0.00015 + float(i)));
    p.y -= 0.02 + 0.10 * spread;
    p = rot(p, -branchLean);
    p = p / 0.67;
    p.y -= 0.72;
    p.x -= side * 0.08 * spread;
    scaleAccum *= 0.67;

    float trunk = segDist(p, vec2(0.0, -0.58), vec2(0.0, 0.18)) * scaleAccum;
    float twig = segDist(p, vec2(0.0, 0.05), vec2(side * 0.22, 0.32)) * scaleAccum;
    float localD = min(trunk, twig);
    if (localD < d) {
      d = localD;
      depthHit = float(i + 1);
    }
  }

  float thickness = 0.020 + 0.004 * smoothstep(0.0, 1.0, -p0.y);
  float branch = 1.0 - smoothstep(thickness, thickness * 2.4, d);

  float leafNoise = hash(floor((p0 + vec2(0.0, 1.0)) * 18.0));
  float canopyShape = smoothstep(1.05, 0.25, length((p0 - vec2(0.0, 0.38)) * vec2(0.85, 1.25)));
  float leafVeil = canopyShape * smoothstep(0.32, 0.95, leafNoise + 0.25 * sin(depthHit + p0.x * 12.0));
  float mass = max(branch, leafVeil * 0.85);

  vec3 bark = vec3(0.30, 0.18, 0.08) * (0.75 + 0.25 * depthHit / max(float(levels), 1.0));
  vec3 leaf = leafPalette(fract(depthHit * 0.13 + p0.y * 0.22), uColorScheme);
  vec3 color = mix(vec3(0.01, 0.015, 0.01), mix(bark, leaf, leafVeil), mass);
  color += vec3(0.75, 0.95, 0.55) * branch * 0.08;

  float alpha = uTransparentBg > 0.5 ? mass : 1.0;
  fragColor = vec4(linearToSRGB(color), alpha);
}
