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

// Harper equation / Hofstadter butterfly
// For rational alpha = p/Q, compute transfer matrix product
// T_n = [[E - 2cos(2*pi*n*alpha), -1], [1, 0]]
// Spectrum point if |Tr(product)| <= 2
//
// We approximate by scanning several Q values and checking
// if the trace condition is satisfied for the pixel (alpha, E).
void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 p = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);

  // Map pixel to (alpha, E) space
  // alpha in [0, 1], E in [-4, 4] (standard Harper range)
  float alpha = p.x;
  float E = p.y;

  int maxQ = int(clamp(uIterations, 10.0, 200.0));

  float minTrace = 1e10;
  float bestQ = 0.0;

  // Check multiple rational approximations
  for (int Q = 2; Q < 200; Q++) {
    if (Q > maxQ) break;

    // For this Q, compute P = round(alpha * Q)
    float fP = floor(alpha * float(Q) + 0.5);
    float ratAlpha = fP / float(Q);

    // Only process if this is a new rational approximation
    // (skip if too far from our alpha)
    if (abs(ratAlpha - alpha) > 0.5 / float(Q)) continue;

    // Compute transfer matrix product for this (alpha, E)
    // Start with identity matrix [[1,0],[0,1]]
    float m00 = 1.0, m01 = 0.0;
    float m10 = 0.0, m11 = 1.0;

    for (int n = 1; n <= 200; n++) {
      if (n > Q) break;

      float diag = E - 2.0 * cos(6.28318 * float(n) * ratAlpha);

      // T_n = [[diag, -1], [1, 0]]
      // product = T_n * product
      float new00 = diag * m00 - m10;
      float new01 = diag * m01 - m11;
      float new10 = m00;
      float new11 = m01;

      m00 = new00;
      m01 = new01;
      m10 = new10;
      m11 = new11;
    }

    float tr = abs(m00 + m11);
    if (tr < minTrace) {
      minTrace = tr;
      bestQ = float(Q);
    }
  }

  // Spectrum point if |Trace| <= 2
  bool isSpectrum = (minTrace <= 2.0);

  if (!isSpectrum) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Color by Q value and trace proximity
  float traceDist = minTrace / 2.0;  // 0 to 1
  float t = fract(bestQ / 64.0 + traceDist * 0.3 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);

  // Fade near boundary
  float edgeFade = smoothstep(2.0, 1.5, minTrace);
  col *= edgeFade;

  fragColor = vec4(linearToSRGB(col), 1.0);
}
