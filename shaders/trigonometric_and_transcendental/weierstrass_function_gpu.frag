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
uniform float uA;

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
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.4)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.7))
    );
  } else if (scheme == 1) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.5)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.3)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.0))
    );
  } else if (scheme == 2) {
    return vec3(
      0.5 + 0.5 * cos(6.28318 * (t + 0.0)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.33)),
      0.5 + 0.5 * cos(6.28318 * (t + 0.67))
    );
  } else if (scheme == 3) {
    float g = 0.5 + 0.5 * cos(6.28318 * t);
    return vec3(g);
  }
  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}

// Weierstrass nowhere-differentiable function
// f(x) = sum_{n=0}^{N} a^n * cos(b^n * pi * x)
float weierstrass(float x, float a_param, float b_param, int terms) {
  float result = 0.0;
  float an = 1.0;       // a^n
  float bn = 1.0;       // b^n
  for (int n = 0; n < 30; n++) {
    if (n >= terms) break;
    result += an * cos(bn * 3.14159265 * x);
    an *= a_param;
    bn *= b_param;
  }
  return result;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  float a_param = clamp(uA, 0.01, 0.99);
  float b_param = 7.0;  // standard Weierstrass b parameter (odd integer, a*b > 1+3pi/2)

  int terms = int(clamp(uIterations, 2.0, 30.0));

  // Compute the function value at x = p.x
  float fx = weierstrass(p.x, a_param, b_param, terms);

  // Also compute a derivative of the function for multiple "layers"
  float fx_dx = weierstrass(p.x + 0.001, a_param, b_param, terms);
  float slope = (fx_dx - fx) / 0.001;

  // Distance from curve: d = |p.y - f(p.x)| / sqrt(1 + slope^2) (approx)
  float dist = abs(p.y - fx) / sqrt(1.0 + slope * slope);

  // Pixel width in world coordinates for anti-aliasing
  float pixW = 1.0 / (max(1.0, scale) * max(0.000001, uZoom));

  // Create multiple density layers for visual richness
  float intensity = 0.0;

  // Main curve: sharp line
  float lineWidth = 2.0 * pixW;
  intensity += smoothstep(lineWidth, 0.0, dist);

  // Glow around curve
  float glowWidth = 20.0 * pixW;
  intensity += 0.4 * smoothstep(glowWidth, 0.0, dist);

  // Additional harmonic overlay: show partial sums
  for (int k = 1; k < 6; k++) {
    float fk = weierstrass(p.x, a_param, b_param, k);
    float dk = abs(p.y - fk);
    intensity += 0.1 * smoothstep(3.0 * pixW, 0.0, dk);
  }

  intensity = clamp(intensity, 0.0, 1.0);

  if (intensity < 0.001) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(dist / (40.0 * pixW) + p.x * 0.5 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt) * intensity;
  fragColor = vec4(linearToSRGB(col), intensity);
}
