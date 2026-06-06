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

// IEC 61966-2-1 sRGB transfer function (linear → display-encoded).
vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

// colorScheme 0-49: standard palette coloring.
// colorScheme 50-63: normal-map (bas-relief) mode — 14 light angles × 4 base palettes.
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

// Cardioid + period-2 bulb membership test (MV2 / Cheritat).
// Points inside never escape — skip the iteration loop entirely.
// Saves ~40% GPU time on standard overview zooms.
bool inMainBulb(vec2 c) {
  float y2 = c.y * c.y;
  float q  = (c.x - 0.25) * (c.x - 0.25) + y2;
  if (q * (q + (c.x - 0.25)) < 0.25 * y2) return true;   // main cardioid
  if ((c.x + 1.0) * (c.x + 1.0) + y2 < 0.0625) return true; // period-2 bulb
  return false;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);

  vec2 z   = vec2(0.0);
  // Complex derivative dz/dc, used for normal-map shading.
  // Recurrence: der_{n+1} = 2 * z_n * der_n + 1   (init: der_0 = 0)
  vec2 der = vec2(0.0);
  float bailoutSq = uBailout * uBailout;

  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = target; // default: inside set

  // Early-out for cardioid / period-2 bulb: these points never escape.
  if (!inMainBulb(c)) {
    it = 0;
    for (int j = 0; j < MAX_ITERS; j++) {
      if (j >= target) { it = target; break; }
      // Derivative update (uses current z, must precede z update):
      //   der = 2 * z * der + 1   (complex multiply, then +1 on real part)
      der = 2.0 * vec2(z.x * der.x - z.y * der.y,
                       z.x * der.y + z.y * der.x) + vec2(1.0, 0.0);
      z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
      if (dot(z, z) > bailoutSq) { it = j; break; }
      it = j + 1;
    }
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Smooth coloring: continuous escape-time with normalization
  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2)) + 4.0;

  // ── Normal-map shading (colorScheme 50-63) ──────────────────────────────
  // Based on the MV2 / Inigo Quilez bas-relief technique.
  // The complex quotient z / f'(z) estimates the outward surface normal
  // of the escape-time isoline. Dotting with a light direction gives
  // diffuse shading that reveals 3D-like fractal topology.
  //
  // Scheme mapping:
  //   50 → light angle   0° + palette 0    57 → light angle ~97° + palette 3
  //   51 →              ~14° + palette 1    58 →            ~111° + palette 0
  //   ...                                   63 →            ~180° + palette 1
  if (schemeInt >= 50) {
    // Map scheme 50-63 → light angle 0..π (14 steps over half a turn).
    float angle = float(schemeInt - 50) * (3.14159265 / 13.0);
    vec2 lightDir = vec2(cos(angle), sin(angle));

    // Normal estimate: nv = z / der  (complex division)
    float denom = max(1e-12, dot(der, der));
    vec2 nv = vec2( z.x * der.x + z.y * der.y,
                    z.y * der.x - z.x * der.y) / denom;

    float nLen = length(nv);
    if (nLen > 1e-6) nv /= nLen;

    // Diffuse + ambient lighting.  HEIGHT controls ambient floor (MV2 default 0.5).
    const float HEIGHT = 0.5;
    float light = clamp((dot(nv, lightDir) + HEIGHT) / (1.0 + HEIGHT), 0.0, 1.0);
    // Gamma 1.8 correction as in MV2 for perceptually pleasing shading.
    light = pow(light, 1.0 / 1.8);

    float baseT   = fract(smoothVal / 64.0 + uTime * 0.0001);
    int basePal   = (schemeInt - 50) - ((schemeInt - 50) / 4) * 4;  // cycle palettes 0-3 across 14 angles
    vec3 col = palette(baseT, basePal) * light;
    fragColor = vec4(linearToSRGB(col), 1.0);
    return;
  }

  float t = fract(smoothVal / 64.0);
  vec3 col = palette(fract(t + uTime * 0.0001), schemeInt);
  fragColor = vec4(linearToSRGB(col), 1.0);
}
