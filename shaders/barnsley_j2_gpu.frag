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

const int MAX_ITERS = 500;

vec3 iqPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 getPaletteColor(float t, int scheme) {
  t = fract(t);
  if (scheme == 0) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.33,0.67));
  if (scheme == 1) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.10,0.20));
  if (scheme == 2) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0,0.7,0.4), vec3(0.0,0.15,0.20));
  if (scheme == 3) return iqPalette(t, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0));
  float s = float(scheme);
  vec3 a = vec3(0.5 + 0.2*sin(s*1.1), 0.5 + 0.2*sin(s*1.3), 0.5 + 0.2*sin(s*1.7));
  vec3 b = vec3(0.5 + 0.3*cos(s*0.7), 0.5 + 0.3*cos(s*1.1), 0.5 + 0.3*cos(s*0.3));
  vec3 c = vec3(1.0 + sin(s*0.5), 1.0 + sin(s*0.9), 1.0 + sin(s*1.3));
  vec3 d = vec3(fract(s*0.13), fract(s*0.17), fract(s*0.23));
  return clamp(iqPalette(t, a, b, c, d), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }
vec2 cadd(vec2 a, vec2 b) { return a + b; }
vec2 csub(vec2 a, vec2 b) { return a - b; }
vec2 cconj(vec2 z) { return vec2(z.x, -z.y); }
vec2 cdiv(vec2 a, vec2 b) {
  float d = max(dot(b,b), 1e-12);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}
vec2 cpow2(vec2 z) { return cmul(z,z); }
vec2 cpow3(vec2 z) { return cmul(cpow2(z), z); }
vec2 cexp(vec2 z) {
  float ex = exp(clamp(z.x, -40.0, 40.0));
  return ex * vec2(cos(z.y), sin(z.y));
}
vec2 csin(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(sin(z.x)*cosh(y), cos(z.x)*sinh(y));
}
vec2 ccos(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(cos(z.x)*cosh(y), -sin(z.x)*sinh(y));
}
vec2 ctan(vec2 z) { return cdiv(csin(z), ccos(z)); }
vec2 csinh(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(sinh(z.x)*cos(y), cosh(z.x)*sin(y));
}
vec2 ccosh(vec2 z) {
  float y = clamp(z.y, -20.0, 20.0);
  return vec2(cosh(z.x)*cos(y), sinh(z.x)*sin(y));
}
vec2 ctanh(vec2 z) { return cdiv(csinh(z), ccosh(z)); }

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 c = uv / max(uZoom, 1e-6) + uCenter;
  vec2 z = uv / max(uZoom, 1e-6) + uCenter;
  vec2 cfix = vec2(0.6, 1.1);

  float bailoutSq = max(4.0, uBailout * uBailout);
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;
    
    vec2 zc = cmul(z, cfix);
    if (zc.x >= 0.0) {
      z = cmul(z - vec2(1.0, 0.0), cfix);
    } else {
      z = cmul(z + vec2(1.0, 0.0), cfix);
    }
    if (dot(z, z) > bailoutSq) { it = j; break; }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float smoothVal = float(it) - log2(log2(max(1e-12, dot(z, z))));
  float t = fract(smoothVal / max(1.0, uIterations) + uTime * 0.0001);
  fragColor = vec4(getPaletteColor(t, int(uColorScheme)), 1.0);
}
