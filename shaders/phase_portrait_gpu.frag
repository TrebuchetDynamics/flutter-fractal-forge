#include <flutter/runtime_effect.glsl>

precision highp float;

// Phase Portrait — argument-only coloring of complex functions.
// Maps the argument (phase) of f(z) to a color wheel and uses magnitude for
// subtle brightness modulation with optional contour rings.
// Extra param: uFunction (float 10).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uFunction;      // 10  (0=z^2, 1=z^3-1, 2=sin(z), 3=exp(z), 4=1/z, 5=z+1/z)

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
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.4)),0.5+0.5*cos(6.28318*(t+0.7)));
  } else if (scheme == 1) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.5)),0.5+0.5*cos(6.28318*(t+0.3)),0.5+0.5*cos(6.28318*(t+0.0)));
  } else if (scheme == 2) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.33)),0.5+0.5*cos(6.28318*(t+0.67)));
  } else if (scheme == 3) {
    float g = 0.5+0.5*cos(6.28318*t); return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0,2.0,3.0) * (0.37*s+0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7,2.3,2.9) * (0.29*s+0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8,1.3,1.7) * (0.11*s+0.3));
  vec3 d = fract(sin(vec3(12.9898,78.233,37.719) * (s+0.5)) * 43758.5453);
  return clamp(a + b * cos(6.28318*(c*t+d)), 0.0, 1.0);
}

vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x); }

vec2 csin(vec2 z) {
  return vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
}

vec2 cexp(vec2 z) {
  float ea = exp(z.x);
  return ea * vec2(cos(z.y), sin(z.y));
}

vec2 cdiv(vec2 a, vec2 b) {
  float d = max(dot(b, b), 1e-20);
  return vec2(a.x*b.x + a.y*b.y, a.y*b.x - a.x*b.y) / d;
}

// HSV to RGB
vec3 hsv2rgb(float h, float s, float v) {
  h = fract(h) * 6.0;
  float c = v * s;
  float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
  float m = v - c;
  vec3 rgb;
  if      (h < 1.0) rgb = vec3(c, x, 0.0);
  else if (h < 2.0) rgb = vec3(x, c, 0.0);
  else if (h < 3.0) rgb = vec3(0.0, c, x);
  else if (h < 4.0) rgb = vec3(0.0, x, c);
  else if (h < 5.0) rgb = vec3(x, 0.0, c);
  else              rgb = vec3(c, 0.0, x);
  return rgb + m;
}

// Evaluate complex function
vec2 evalFunc(vec2 z, int funcId) {
  if (funcId == 0) {
    return cmul(z, z);
  } else if (funcId == 1) {
    return cmul(cmul(z, z), z) - vec2(1.0, 0.0);
  } else if (funcId == 2) {
    return csin(z);
  } else if (funcId == 3) {
    return cexp(z);
  } else if (funcId == 4) {
    // 1/z
    return cdiv(vec2(1.0, 0.0), z);
  } else {
    // z + 1/z (Joukowski-type)
    return z + cdiv(vec2(1.0, 0.0), z);
  }
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  int funcId    = int(uFunction);

  // Evaluate the complex function
  vec2 fz = evalFunc(z, funcId);

  // Phase (argument) and magnitude
  float phase = atan(fz.y, fz.x);    // [-pi, pi]
  float hue   = phase / 6.28318 + 0.5; // [0, 1]
  float mag   = length(fz);

  // Subtle brightness modulation from magnitude using log scale
  float logMag   = log2(mag + 1.0);
  float brightness = 0.5 + 0.5 * (1.0 - 2.0 / (2.0 + logMag));
  brightness = clamp(brightness, 0.35, 1.0);

  // Magnitude contour rings as subtle brightness perturbation
  float magFrac  = fract(log2(mag + 1.0));
  float ringDist = min(magFrac, 1.0 - magFrac);
  float ring     = smoothstep(0.0, 0.08, ringDist);
  brightness *= 0.7 + 0.3 * ring;

  // ── Normal-map shading (colorScheme 50-63) ────────────────────────────────
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Finite-difference gradient of |f(z)|
    float eps = 0.5 / (max(0.000001, uZoom) * scale);
    vec2 fzR = evalFunc(z + vec2(eps, 0.0), funcId);
    vec2 fzU = evalFunc(z + vec2(0.0, eps), funcId);
    float magR = length(fzR);
    float magU = length(fzU);
    vec2 grad = vec2(magR - mag, magU - mag) / eps;
    float gradLen = length(grad);
    vec2 nv = (gradLen > 1e-6) ? grad / gradLen : vec2(0.0);

    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    light = pow(light, 1.0 / 1.8);

    int basePal = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;
    float baseT = fract(hue + uTime * 0.0001);
    vec3 color = palette(baseT, basePal) * light * brightness;
    fragColor = vec4(linearToSRGB(color), 1.0);
    return;
  }

  // Phase portrait: hue from argument, brightness from magnitude
  hue = fract(hue + uTime * 0.00005);

  vec3 color;
  if (schemeInt == 0) {
    // Pure HSV color wheel
    color = hsv2rgb(hue, 0.9, brightness);
  } else if (schemeInt < 50) {
    // Use palette driven by phase
    vec3 palCol = palette(hue, schemeInt);
    color = palCol * brightness;
  } else {
    color = hsv2rgb(hue, 0.9, brightness);
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
