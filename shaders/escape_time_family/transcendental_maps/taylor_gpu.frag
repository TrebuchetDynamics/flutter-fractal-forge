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

// Shared: linearToSRGB, iqPalette, getPaletteColorAlt
#include "../../shared/color.glsl"

const int MAX_ITERS = 500;

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
  vec2 z = vec2(0.0);

  float bailoutSq = max(4.0, uBailout * uBailout);
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target;
  float orbit = 0.0;
  float trap = 1e9;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) break;
    
    vec2 term = vec2(1.0, 0.0);
    vec2 sum = term;
    float fact = 1.0;
    const int N = 8;
    for (int k = 1; k <= N; k++) {
      fact *= float(k);
      term = cmul(term, z);
      sum += term / fact;
    }
    z = sum + c;
    float r2 = dot(z, z);
    orbit += exp(-0.45 * r2);
    trap = min(trap, min(abs(z.x), abs(z.y)));
    if (r2 > bailoutSq) { it = j; break; }
  }

  if (it >= target) {
    float n = clamp(orbit / max(1.0, float(target)), 0.0, 1.0);
    float tBound = fract(0.65 * n - 0.10 * log(max(trap, 1e-6)) + uTime * 0.0001);
    vec3 col = getPaletteColorAlt(tBound, int(uColorScheme)) * (0.35 + 0.65 * n);
    fragColor = vec4(linearToSRGB(col), uTransparentBg > 0.5 ? 0.9 : 1.0);
    return;
  }

  float smoothVal = float(it) - log2(log2(max(1.000001, dot(z,z))));
  float t = fract(smoothVal / 64.0 + uTime * 0.0001);
  fragColor = vec4(linearToSRGB(getPaletteColorAlt(t, int(uColorScheme))), 1.0);
}
