#include <flutter/runtime_effect.glsl>

precision highp float;

// Domain Coloring for complex function visualization.
// Maps f(z) output to color using argument (phase) → hue and magnitude → brightness.
// Supports multiple complex functions and contour modes.
// Extra params: uFunction (float 10), uContours (float 11).
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9
uniform float uFunction;      // 10  (0=z^2, 1=z^3-1, 2=sin(z), 3=exp(z), 4=z^2+c)
uniform float uContours;      // 11  (0=off, 1=magnitude rings, 2=grid lines)

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

// Complex sin: sin(a+bi) = sin(a)cosh(b) + i*cos(a)sinh(b)
vec2 csin(vec2 z) {
  return vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
}

// Complex exp: exp(a+bi) = exp(a)(cos(b) + i*sin(b))
vec2 cexp(vec2 z) {
  float ea = exp(z.x);
  return ea * vec2(cos(z.y), sin(z.y));
}

// HSV to RGB conversion
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

// Evaluate complex function f(z) based on uFunction selector
vec2 evalFunc(vec2 z, vec2 c, int funcId) {
  if (funcId == 0) {
    // z^2
    return cmul(z, z);
  } else if (funcId == 1) {
    // z^3 - 1
    return cmul(cmul(z, z), z) - vec2(1.0, 0.0);
  } else if (funcId == 2) {
    // sin(z)
    return csin(z);
  } else if (funcId == 3) {
    // exp(z)
    return cexp(z);
  } else {
    // z^2 + c  (c derived from iteration seed)
    return cmul(z, z) + c;
  }
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);

  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt   = int(uColorScheme);
  int funcId      = int(uFunction);
  int contourMode = int(uContours);

  // For function 4 (z^2+c), use a seed c based on time animation
  float timeAngle = uTime * 0.0003;
  vec2 cSeed = vec2(0.7885 * cos(timeAngle), 0.7885 * sin(timeAngle));

  // Evaluate the complex function
  vec2 fz = evalFunc(z, cSeed, funcId);

  // Compute phase (argument) and magnitude
  float phase = atan(fz.y, fz.x);  // range [-pi, pi]
  float hue   = phase / 6.28318 + 0.5; // map to [0, 1]
  float mag   = length(fz);

  // Brightness from magnitude: use log scale for better visualization
  float logMag = log2(mag + 1.0);
  float brightness = 1.0 - 1.0 / (1.0 + logMag * 0.3);
  brightness = clamp(brightness * 0.6 + 0.4, 0.2, 1.0);

  // Contour lines
  float contourDarken = 1.0;
  if (contourMode == 1) {
    // Magnitude rings: dark bands where |f(z)| crosses integer values
    float magFrac = fract(mag);
    float ringWidth = 0.06;
    // Smooth dark band near integer magnitudes
    float dist = min(magFrac, 1.0 - magFrac);
    contourDarken = smoothstep(0.0, ringWidth, dist);
    contourDarken = 0.3 + 0.7 * contourDarken;
  } else if (contourMode == 2) {
    // Grid lines: dark bands along Re(f(z)) and Im(f(z)) integer crossings
    float rFrac = fract(fz.x);
    float iFrac = fract(fz.y);
    float gridWidth = 0.05;
    float dR = min(rFrac, 1.0 - rFrac);
    float dI = min(iFrac, 1.0 - iFrac);
    float gridR = smoothstep(0.0, gridWidth, dR);
    float gridI = smoothstep(0.0, gridWidth, dI);
    contourDarken = 0.3 + 0.7 * min(gridR, gridI);
  }

  vec3 color;

  // ── Normal-map shading (colorScheme 50-63) ────────────────────────────────
  // For domain coloring, we use finite differences to estimate a "normal"
  // from the magnitude surface and light it.
  if (schemeInt >= 50) {
    float angle   = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Finite-difference gradient of |f(z)| for normal estimation
    float eps = 0.5 / (max(0.000001, uZoom) * scale);
    vec2 fzR = evalFunc(z + vec2(eps, 0.0), cSeed, funcId);
    vec2 fzU = evalFunc(z + vec2(0.0, eps), cSeed, funcId);
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
    color = palette(baseT, basePal) * light * contourDarken;
    fragColor = vec4(linearToSRGB(color), 1.0);
    return;
  }

  // Standard domain coloring: phase → hue, magnitude → brightness
  // When colorScheme < 50, use HSV-based domain coloring
  hue = fract(hue + uTime * 0.00005);
  color = hsv2rgb(hue, 0.85, brightness * contourDarken);

  // Blend with palette color for non-zero schemes
  if (schemeInt > 0 && schemeInt < 50) {
    vec3 palCol = palette(hue, schemeInt);
    color = mix(color, palCol * brightness * contourDarken, 0.6);
  }

  fragColor = vec4(linearToSRGB(color), 1.0);
}
