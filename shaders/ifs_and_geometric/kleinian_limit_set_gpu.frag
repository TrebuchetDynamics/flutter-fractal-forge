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
uniform float uTraceReal;
uniform float uTraceImag;

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

// Complex multiply
vec2 cmul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

// Complex divide
vec2 cdiv(vec2 a, vec2 b) {
  float denom = dot(b, b);
  return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / max(denom, 1e-12);
}

// Mobius transformation: f(z) = (a*z + b) / (c*z + d)
vec2 mobius(vec2 z, vec2 ma, vec2 mb, vec2 mc, vec2 md) {
  vec2 num = cmul(ma, z) + mb;
  vec2 den = cmul(mc, z) + md;
  return cdiv(num, den);
}

// Pseudo-random from seed
float hash(float n) {
  return fract(sin(n) * 43758.5453);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5 * uResolution) / max(1.0, scale);
  vec2 z = uv / max(0.000001, uZoom) + uCenter;

  int schemeInt = int(uColorScheme);
  int maxIter = int(clamp(uIterations, 10.0, 500.0));

  // Kleinian group generators from trace parameters
  // Generator 1: trace = traceReal + i*traceImag
  vec2 tr1 = vec2(uTraceReal, uTraceImag);
  // Generator 2: trace = 2 (parabolic element)
  vec2 tr2 = vec2(2.0, 0.0);

  // Build Mobius generators from traces (Riley slice parameterization)
  // f1(z) = tr1*z - 1 (simplified: a=tr1/2, b=-1, c=1, d=tr1/2 for SL(2,C))
  // Actually use the standard Grandma's recipe / Riley slice construction:
  // S = [[tr1/2, i], [i, tr1/2]] (scaled)
  // T = [[tr2/2, c], [0, 2/tr2]] where c is computed from traces

  vec2 half_tr1 = tr1 * 0.5;

  // Generator 1: z -> (half_tr1 * z + 1) / (z + half_tr1)
  vec2 a1 = half_tr1;
  vec2 b1 = vec2(1.0, 0.0);
  vec2 c1 = vec2(1.0, 0.0);
  vec2 d1 = half_tr1;

  // Generator 2: z -> (z + c_param) / 1, or parabolic: z -> z + c_param
  // Use T: z -> z + c_param where c_param = tr1^2 - 4 (Maskit slice-like)
  vec2 tr1sq = cmul(tr1, tr1);
  vec2 c_param = tr1sq - vec2(4.0, 0.0);
  vec2 a2 = vec2(1.0, 0.0);
  vec2 b2 = c_param;
  vec2 c2 = vec2(0.0, 0.0);
  vec2 d2 = vec2(1.0, 0.0);

  // Iterate: apply random sequence of generators
  float density = 0.0;
  vec2 orbit = z;
  float minDist = 1e10;

  // Deterministic orbit using pixel position as seed
  float seed = dot(fragCoord, vec2(127.1, 311.7));

  for (int i = 0; i < 500; i++) {
    if (i >= maxIter) break;

    // Choose generator based on pseudo-random sequence
    float r = hash(seed + float(i) * 1.618);
    int choice = int(r * 4.0);

    if (choice == 0) {
      orbit = mobius(orbit, a1, b1, c1, d1);
    } else if (choice == 1) {
      // Inverse of generator 1: swap a<->d, negate b,c
      orbit = mobius(orbit, d1, -b1, -c1, a1);
    } else if (choice == 2) {
      orbit = mobius(orbit, a2, b2, c2, d2);
    } else {
      orbit = mobius(orbit, d2, -b2, -c2, a2);
    }

    // Track distance to original point
    float d = length(orbit - z);
    minDist = min(minDist, d);

    // Check if orbit stays bounded
    if (length(orbit) > uBailout) break;

    // Accumulate density
    density += 1.0 / (1.0 + d * d);
  }

  float normDensity = density / float(maxIter);

  if (normDensity < 0.001 && minDist > 1.0) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  float t = fract(normDensity * 3.0 + log(max(minDist, 1e-6)) * 0.1 + uTime * 0.0001);
  vec3 col = palette(t, schemeInt);

  float alpha = clamp(normDensity * 5.0, 0.0, 1.0);
  col *= alpha;

  float outAlpha = (uTransparentBg > 0.5) ? alpha : 1.0;
  fragColor = vec4(linearToSRGB(col), outAlpha);
}
