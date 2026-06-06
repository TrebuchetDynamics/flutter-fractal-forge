#include <flutter/runtime_effect.glsl>

precision highp float;

// Hydrogen Orbital Density — stylized volumetric renderer for the prompt:
//   Ψ(x,y,z) = (1/√(8π)) * (1 - r/2) * e^(-r/2) * Y_{2,0}(θ,φ)
//   Φ = |Ψ|²
//   Δ = noise_perlin(4x,4y,4z) * 0.4 for r > 1.2
//   color(ρ) = ρ < 0.1 → void black, ρ > 0.6 → hydrogen blue to white
// Note: the radial term and Y_20 angular harmonic are a creative hybrid, not a
// physically valid single hydrogen eigenstate. The shader keeps that hybrid on
// purpose because it is the source prompt's visual recipe.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec3  uRotation;      // 3-5
uniform float uZoom;          // 6
uniform float uDensityGain;   // 7
uniform float uNoiseStrength; // 8
uniform float uRadialScale;   // 9
uniform float uSteps;         // 10
uniform float uColorScheme;   // 11
uniform float uTransparentBg; // 12

out vec4 fragColor;

const float PI = 3.141592653589793;
const float INV_SQRT_8PI = 0.19947114020071635;
const float Y20_NORM = 0.31539156525252005; // sqrt(5 / (16π))
const int MAX_STEPS = 180;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

mat3 rotationMatrix(vec3 angles) {
  float cx = cos(angles.x), sx = sin(angles.x);
  float cy = cos(angles.y), sy = sin(angles.y);
  float cz = cos(angles.z), sz = sin(angles.z);
  return mat3(
    cy * cz, sx * sy * cz - cx * sz, cx * sy * cz + sx * sz,
    cy * sz, sx * sy * sz + cx * cz, cx * sy * sz - sx * cz,
    -sy,     sx * cy,                cx * cy
  );
}

float hash31(vec3 p) {
  p = fract(p * 0.3183099 + vec3(0.11, 0.17, 0.13));
  p *= 17.0;
  return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// Compact 3D value noise used as a Perlin-like perturbation field.
float noise3D(vec3 p) {
  vec3 i = floor(p);
  vec3 f = fract(p);
  vec3 u = f * f * (3.0 - 2.0 * f);

  float n000 = hash31(i + vec3(0.0, 0.0, 0.0));
  float n100 = hash31(i + vec3(1.0, 0.0, 0.0));
  float n010 = hash31(i + vec3(0.0, 1.0, 0.0));
  float n110 = hash31(i + vec3(1.0, 1.0, 0.0));
  float n001 = hash31(i + vec3(0.0, 0.0, 1.0));
  float n101 = hash31(i + vec3(1.0, 0.0, 1.0));
  float n011 = hash31(i + vec3(0.0, 1.0, 1.0));
  float n111 = hash31(i + vec3(1.0, 1.0, 1.0));

  float nx00 = mix(n000, n100, u.x);
  float nx10 = mix(n010, n110, u.x);
  float nx01 = mix(n001, n101, u.x);
  float nx11 = mix(n011, n111, u.x);
  float nxy0 = mix(nx00, nx10, u.y);
  float nxy1 = mix(nx01, nx11, u.y);
  return mix(nxy0, nxy1, u.z);
}

vec2 raySphere(vec3 origin, vec3 dir, float radius) {
  float b = dot(origin, dir);
  float c = dot(origin, origin) - radius * radius;
  float h = b * b - c;
  if (h < 0.0) {
    return vec2(1.0, -1.0);
  }
  h = sqrt(h);
  return vec2(-b - h, -b + h);
}

float orbitalDensity(vec3 p) {
  float scale = max(uRadialScale, 0.1);
  vec3 q = p / scale;
  float r = length(q);

  float cosTheta = q.z / max(r, 1e-4);
  float y20 = Y20_NORM * (3.0 * cosTheta * cosTheta - 1.0);
  float radial = INV_SQRT_8PI * (1.0 - 0.5 * r) * exp(-0.5 * r);
  float psi = radial * y20;

  // Raw |ψ|² is tiny (~1e-2). Normalize into the prompt's ρ thresholds.
  float rho = psi * psi * 48.0 * max(uDensityGain, 0.0);

  // Prompt perturbation: Δ = noise_perlin(4x,4y,4z) * 0.4 for r > 1.2.
  // The phase is periodic, so animation/export loops do not jump abruptly.
  float phase = uTime * 0.00035;
  vec3 loopOffset = vec3(cos(phase), sin(phase), cos(phase + 2.0943951));
  float shell = smoothstep(1.2, 1.6, r);
  float n = noise3D(q * 4.0 + loopOffset);
  rho += shell * uNoiseStrength * 0.4 * (n * 2.0 - 1.0);

  return clamp(rho, 0.0, 2.0);
}

vec3 densityColor(float rho, vec3 p) {
  int schemeRaw = int(uColorScheme);
  int scheme = schemeRaw - (schemeRaw / 4) * 4;
  float matter = smoothstep(0.10, 0.60, rho);
  float hot = smoothstep(0.60, 1.20, rho);
  float radialGlow = 1.0 - smoothstep(0.2, 3.8 * max(uRadialScale, 0.1), length(p));

  vec3 hydrogenBlue = vec3(0.03, 0.36, 1.0);
  vec3 col = mix(vec3(0.0, 0.025, 0.08), hydrogenBlue, matter);
  col = mix(col, vec3(1.0), hot);

  if (scheme == 1) {
    col = mix(vec3(0.02, 0.18, 0.40), vec3(0.65, 0.95, 1.0), matter);
    col = mix(col, vec3(1.0, 0.95, 0.70), hot);
  } else if (scheme == 2) {
    col = mix(vec3(0.12, 0.00, 0.24), vec3(0.55, 0.22, 1.0), matter);
    col = mix(col, vec3(1.0, 0.95, 1.0), hot);
  } else if (scheme == 3) {
    col = vec3(mix(0.02, 1.0, clamp(rho, 0.0, 1.0)));
  }

  return col * (0.58 + 0.42 * radialGlow);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / max(1.0, uResolution.y);

  float objectRadius = 4.0 * max(uRadialScale, 0.4);
  float zoom = max(uZoom, 0.15);
  mat3 rot = rotationMatrix(uRotation);

  vec3 camPos = rot * vec3(0.0, 0.0, objectRadius * 1.65 / zoom);
  vec3 forward = normalize(-camPos);
  vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
  vec3 up = cross(forward, right);
  vec3 rayDir = normalize(forward + uv.x * right + uv.y * up);

  vec2 hit = raySphere(camPos, rayDir, objectRadius);
  vec3 background = mix(vec3(0.0, 0.0, 0.015), vec3(0.0, 0.018, 0.055), uv.y * 0.5 + 0.5);

  if (hit.x > hit.y) {
    fragColor = (uTransparentBg > 0.5)
      ? vec4(0.0)
      : vec4(linearToSRGB(background), 1.0);
    return;
  }

  float t0 = max(hit.x, 0.0);
  float t1 = hit.y;
  int steps = int(clamp(uSteps, 32.0, float(MAX_STEPS)));
  float dt = (t1 - t0) / max(float(steps), 1.0);

  vec3 accumColor = vec3(0.0);
  float accumAlpha = 0.0;

  for (int i = 0; i < MAX_STEPS; i++) {
    if (i >= steps) {
      break;
    }

    float jitter = noise3D(vec3(uv * 19.0, float(i) * 0.37));
    float t = t0 + (float(i) + 0.35 + 0.3 * jitter) * dt;
    vec3 p = camPos + rayDir * t;

    float rho = orbitalDensity(p);
    float matter = smoothstep(0.10, 0.60, rho);
    if (matter > 0.001) {
      vec3 sampleColor = densityColor(rho, p);
      float sampleAlpha = matter * (0.045 + 0.075 * clamp(rho, 0.0, 1.0)) * dt;
      sampleAlpha = clamp(sampleAlpha, 0.0, 0.18);

      // Front-to-back compositing in linear color.
      float oneMinusA = 1.0 - accumAlpha;
      accumColor += oneMinusA * sampleColor * sampleAlpha;
      accumAlpha += oneMinusA * sampleAlpha;

      if (accumAlpha > 0.985) {
        break;
      }
    }
  }

  if (uTransparentBg > 0.5) {
    vec3 straightColor = accumAlpha > 1e-4 ? accumColor / accumAlpha : vec3(0.0);
    fragColor = vec4(linearToSRGB(straightColor), accumAlpha);
  } else {
    vec3 outColor = accumColor + background * (1.0 - accumAlpha);
    fragColor = vec4(linearToSRGB(outColor), 1.0);
  }
}
