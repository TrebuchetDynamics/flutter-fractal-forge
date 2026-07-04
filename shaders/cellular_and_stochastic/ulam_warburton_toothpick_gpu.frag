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
uniform float uAutomatonMode;
uniform float uCellScale;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

float oddDigitShell(float x, float y, float maxGen) {
  x = abs(floor(x));
  y = abs(floor(y));
  float onCell = 0.0;
  float age = 0.0;
  for (int k = 0; k < 12; k++) {
    float pow2 = exp2(float(k));
    if (pow2 > maxGen) break;
    float dx = mod(floor(x / pow2), 2.0);
    float dy = mod(floor(y / pow2), 2.0);
    float born = abs(dx - dy);
    onCell = max(onCell, born);
    age += born * pow2;
  }
  return onCell * (0.2 + 0.8 * fract(age / max(maxGen, 1.0)));
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.5);
  vec3 b = vec3(0.5);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 3.0) { a = vec3(0.06, 0.12, 0.25); b = vec3(0.24, 0.36, 0.55); d = vec3(0.56, 0.24, 0.05); }
  else if (s < 6.0) { a = vec3(0.28, 0.12, 0.04); b = vec3(0.55, 0.26, 0.10); c = vec3(1.0, 0.75, 0.35); d = vec3(0.0, 0.14, 0.3); }
  return a + b * cos(6.28318 * (c * t + d));
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scalePix = max(1.0, min(uResolution.x, uResolution.y));
  vec2 uv = (fragCoord - 0.5 * uResolution) / scalePix;
  vec2 p = uv * 2.2 / max(uZoom, 0.0001) + uCenter;
  float cellScale = clamp(uCellScale, 20.0, 160.0);
  vec2 gp = p * cellScale;
  vec2 cell = floor(gp);
  vec2 f = fract(gp) - 0.5;
  float gen = clamp(uIterations, 8.0, 128.0);
  float mode = floor(clamp(uAutomatonMode, 0.0, 1.0) + 0.5);

  float onCell;
  if (mode < 0.5) {
    onCell = oddDigitShell(cell.x, cell.y, gen);
  } else {
    float ax = abs(cell.x);
    float ay = abs(cell.y);
    float shell = ax + ay;
    float line = min(abs(f.x), abs(f.y));
    float tooth = step(shell, gen) * step(0.0, shell) * (1.0 - smoothstep(0.05, 0.24, line));
    float parity = mod(ax + 2.0 * ay, 3.0);
    onCell = tooth * (0.35 + 0.65 * step(1.0, parity));
  }

  float grid = 1.0 - smoothstep(0.46, 0.50, max(abs(f.x), abs(f.y)));
  float diamond = exp(-abs(abs(cell.x) + abs(cell.y) - gen * 0.55) * 0.04);
  vec3 color = palette(fract(onCell + diamond * 0.35), uColorScheme) * onCell * grid;
  color += vec3(0.8, 0.9, 1.0) * diamond * onCell * 0.18;
  float alpha = onCell * grid;
  if (uTransparentBg <= 0.5) {
    color = mix(vec3(0.006, 0.007, 0.012), color, clamp(alpha, 0.0, 1.0));
    alpha = 1.0;
  }
  fragColor = vec4(linearToSRGB(color), alpha);
}
