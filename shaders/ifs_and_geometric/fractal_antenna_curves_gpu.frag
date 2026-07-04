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
uniform float uMode;
uniform float uWireWidth;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float segDist(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
  return length(pa - ba * h);
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.48);
  vec3 b = vec3(0.50);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 3.0) { a = vec3(0.38, 0.22, 0.08); b = vec3(0.45, 0.30, 0.12); c = vec3(1.0, 0.75, 0.35); d = vec3(0.0, 0.12, 0.26); }
  else if (s < 6.0) { a = vec3(0.06, 0.12, 0.24); b = vec3(0.24, 0.38, 0.52); d = vec3(0.12, 0.32, 0.63); }
  return a + b * cos(6.28318 * (c * t + d));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p0 = uv * 3.1 / max(uZoom, 0.0001) + uCenter;
  float mode = floor(clamp(uMode, 0.0, 2.0) + 0.5);
  int levels = int(clamp(uIterations / 12.0, 3.0, 12.0));
  float d = 10.0;
  float levelHit = 0.0;

  if (mode < 0.5) {
    vec2 p = p0;
    float sc = 1.0;
    for (int i = 0; i < 12; i++) {
      if (i >= levels) break;
      vec2 q = abs(p);
      d = min(d, segDist(q, vec2(-0.72, 0.0), vec2(0.72, 0.0)) * sc);
      d = min(d, segDist(q, vec2(0.72, -0.28), vec2(0.72, 0.28)) * sc);
      p = vec2(abs(p.x) - 0.62, abs(p.y) - 0.20) * 2.0;
      sc *= 0.5;
      levelHit = float(i);
    }
  } else if (mode < 1.5) {
    vec2 p = p0;
    float sc = 1.0;
    for (int i = 0; i < 12; i++) {
      if (i >= levels) break;
      d = min(d, segDist(p, vec2(-0.55, 0.0), vec2(0.55, 0.0)) * sc);
      d = min(d, segDist(p, vec2(-0.55, -0.32), vec2(-0.55, 0.32)) * sc);
      d = min(d, segDist(p, vec2(0.55, -0.32), vec2(0.55, 0.32)) * sc);
      p = abs(p) * 2.0 - vec2(0.70, 0.42);
      sc *= 0.5;
      levelHit = float(i);
    }
  } else {
    vec2 p = p0;
    float sc = 1.0;
    for (int i = 0; i < 12; i++) {
      if (i >= levels) break;
      p = abs(p);
      d = min(d, segDist(p, vec2(-0.55, 0.0), vec2(0.55, 0.0)) * sc);
      d = min(d, segDist(p, vec2(0.0, -0.55), vec2(0.0, 0.55)) * sc);
      p = p * 2.0 - vec2(0.62, 0.62);
      sc *= 0.5;
      levelHit = float(i);
    }
  }

  float width = clamp(uWireWidth, 0.004, 0.06) / max(uZoom, 0.25);
  float wire = 1.0 - smoothstep(width, width * 2.4, d);
  float glow = exp(-d * 45.0);
  vec3 color = palette(fract(levelHit * 0.11 + mode * 0.21), uColorScheme) * (0.45 + 0.85 * max(wire, glow * 0.35));
  color += vec3(1.0, 0.82, 0.45) * wire * 0.22;
  float alpha = uTransparentBg > 0.5 ? max(wire, glow * 0.35) : 1.0;
  if (uTransparentBg <= 0.5) color = mix(vec3(0.008, 0.008, 0.014), color, alpha);
  fragColor = vec4(linearToSRGB(color), alpha);
}
