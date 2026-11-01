#include <flutter/runtime_effect.glsl>

precision highp float;

// Imordial Brot — clean-room ray-marched escape set in Bristorian algebra.
//
// The algebra ("imordials") keeps ranked imaginary units with the product rule
//     e_a * e_b = sgn(b - a) * e_b   (a != b),    e_a * e_a = -1
// so e1*e2 = +e2 and e2*e1 = -e1. It is non-commutative, non-associative and
// non-alternative, and there is no i*j = k. A 4-vector (real, e1, e2, e3) is
// therefore a genuinely different numbering system from the quaternion,
// bicomplex and tricomplex slices already in this catalog.
//
// Because the algebra is not associative the cubic map depends on bracketing,
// so both brackets are exposed as separate variants:
//   variant 0: z^2 + c        (quadratic Mandelbrot family)
//   variant 1: z^2 + c        (quadratic Julia family, documented constant)
//   variant 2: (z*z)*z + c    (left-bracketed cubic)
//   variant 3: z*(z*z) + c    (right-bracketed cubic)
//
// Reference for the product, square and Jacobian: bristorbrot.org (MIT,
// (c) 2026 Doug Bristor). This shader is an independent implementation of the
// documented rule and the distance-estimate march used by the other entries in
// this directory; no third-party shader source was copied.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uMousePos;      // 3-4, pan target
uniform float uZoom;          // 5
uniform vec3  uRotation;      // 6-8
uniform float uPower;         // 9    section roll, degrees
uniform float uIterations;    // 10
uniform float uSteps;         // 11
uniform float uBailout;       // 12   escape radius
uniform float uColorScheme;   // 13
uniform float uFractalType;   // 14   variant
uniform float uTransparentBg; // 15
uniform float uSliceW;        // 16   offset along the fourth slot

out vec4 fragColor;

const int MAX_ITERS = 32;

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

vec3 palette(float t, float scheme) {
  int s = int(mod(scheme, 4.0));
  if (s == 1) return 0.45 + 0.45 * cos(6.28318 * (vec3(0.05, 0.35, 0.60) + t));
  if (s == 2) return 0.45 + 0.45 * cos(6.28318 * (vec3(0.80, 0.45, 0.15) + t));
  if (s == 3) return mix(vec3(0.06, 0.08, 0.12), vec3(0.95, 0.92, 0.82), t);
  return 0.45 + 0.45 * cos(6.28318 * (vec3(0.00, 0.18, 0.38) + t));
}

// ---------------------------------------------------------------- algebra ----
vec4 imMul(vec4 a, vec4 b) {
  return vec4(
    a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w,
    a.x * b.y + a.y * b.x + b.y * (-a.z - a.w),
    a.x * b.z + a.z * b.x + b.z * ( a.y - a.w),
    a.x * b.w + a.w * b.x + b.w * ( a.y + a.z)
  );
}

vec4 imSquare(vec4 z) {
  return vec4(
    z.x * z.x - z.y * z.y - z.z * z.z - z.w * z.w,
    z.y * (2.0 * z.x - z.z - z.w),
    z.z * (2.0 * z.x + z.y - z.w),
    z.w * (2.0 * z.x + z.y + z.z)
  );
}

// Derivative of the square along v: z*v + v*z (bilinear product rule, which
// needs no associativity).
vec4 imSquareJv(vec4 z, vec4 v) {
  return imMul(z, v) + imMul(v, z);
}

// ------------------------------------------------------------- distance ------
float imDistance(vec3 point, out float orbit) {
  int variant = int(clamp(uFractalType, 0.0, 3.0));
  bool julia = (variant == 1);
  bool cubic = (variant >= 2);

  // Section roll: mixes the second world axis with the fourth algebra slot, so
  // rolling through 0..90 degrees sweeps a family of 4D sections.
  float roll = radians(clamp(uPower, 0.0, 90.0));
  float cr = cos(roll), sr = sin(roll);
  float w = clamp(uSliceW, -1.0, 1.0) + 0.10 * sin(uTime * 0.00030);

  vec4 seed = vec4(
    point.x,
    sr * point.y + cr * w,
    cr * point.y - sr * w,
    point.z
  );

  vec4 c = julia ? vec4(-0.7, -0.35, 0.05, 0.0) : seed;
  vec4 z = julia ? seed : vec4(0.0, 0.0, 0.0, 0.0);
  // Mandelbrot family: z0 = 0, dz/dc = 0, and each step carries +dc.
  // Julia family: z0 = seed, dz/d(seed) = 1, and no +dc term is carried.
  vec4 dz = julia ? vec4(1.0, 0.0, 0.0, 0.0) : vec4(0.0, 0.0, 0.0, 0.0);

  float limit = max(1.5, uBailout);
  float limit2 = limit * limit;
  int maxIter = int(clamp(uIterations, 2.0, float(MAX_ITERS)));
  float r2 = 0.0;
  orbit = 1e9;

  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= maxIter) break;

    vec4 square = imSquare(z);
    if (cubic) {
      // f = (z*z)*z or z*(z*z); derivative by the product rule.
      vec4 dSquare = imSquareJv(z, dz);
      if (variant == 2) {
        dz = imMul(dSquare, z) + imMul(square, dz);
        z = imMul(square, z);
      } else {
        dz = imMul(dz, square) + imMul(z, dSquare);
        z = imMul(z, square);
      }
    } else {
      dz = imSquareJv(z, dz);
      z = square;
    }

    z += c;
    if (!julia) dz += vec4(1.0, 0.0, 0.0, 0.0);

    r2 = dot(z, z);
    orbit = min(orbit, sqrt(r2));
    if (r2 > limit2) break;
  }

  float r = max(sqrt(r2), 1.0001);
  float dr = max(length(dz), 1e-8);
  // Hubbard-Douady style estimator for a degree-d map; the log term keeps the
  // surface from overstepping near the boundary.
  return 0.5 * log(r) * r / dr;
}

float sceneDistance(vec3 p, out float orbit) {
  // The escape set is contained in a ball; outside it the distance to the ball
  // is a valid lower bound and lets rays leave quickly.
  float bound = 2.6;
  float outside = length(p) - bound;
  if (outside > 0.0) {
    orbit = 1e9;
    return outside;
  }
  return max(imDistance(p, orbit), 0.0002);
}

vec3 getNormal(vec3 p) {
  float e = 0.0016;
  float o;
  vec2 h = vec2(e, 0.0);
  return normalize(vec3(
    sceneDistance(p + h.xyy, o) - sceneDistance(p - h.xyy, o),
    sceneDistance(p + h.yxy, o) - sceneDistance(p - h.yxy, o),
    sceneDistance(p + h.yyx, o) - sceneDistance(p - h.yyx, o)
  ));
}

float ambientOcclusion(vec3 p, vec3 n) {
  float occ = 0.0;
  float sca = 1.0;
  float o;
  for (int i = 1; i <= 5; i++) {
    float h = 0.03 * float(i);
    float d = sceneDistance(p + n * h, o);
    occ += (h - d) * sca;
    sca *= 0.6;
  }
  return clamp(1.0 - occ * 2.2, 0.0, 1.0);
}

// Orbit radius at the accepted hit, consumed by the shading pass.
float gHitOrbit = 1.0;

vec4 rayMarch(vec3 ro, vec3 rd) {
  float t = 0.0;
  float orbit = 1.0;
  int maxSteps = int(clamp(uSteps, 30.0, 200.0));
  float baseEps = 0.0022 / max(uZoom, 0.1);
  float reach = length(ro) + 4.0;
  for (int i = 0; i < 200; i++) {
    if (i >= maxSteps) break;
    vec3 p = ro + rd * t;
    float d = sceneDistance(p, orbit);
    // The hit threshold grows with distance so far-field grazing rays do not
    // register as surface hits (which reads as speckle in the background).
    if (d < baseEps * (1.0 + t * 0.35)) {
      gHitOrbit = orbit;
      return vec4(p, float(i));
    }
    t += d * 0.90;
    if (t > reach) break;
  }
  return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

  mat3 rot = rotationMatrix(uRotation);
  vec3 target = vec3(uMousePos, 0.0);
  vec3 ro = target + rot * vec3(0.0, 0.0, 2.05 / max(uZoom, 0.1));
  vec3 rd = normalize(rot * vec3(uv.x, uv.y, -1.5));

  vec4 hit = rayMarch(ro, rd);
  vec3 color;
  float alpha;

  if (hit.w >= 0.0) {
    vec3 n = getNormal(hit.xyz);
    vec3 lightA = normalize(vec3(4.0, 5.0, 3.0));
    vec3 lightB = normalize(vec3(-3.0, 2.0, -4.0));
    float diff = max(dot(n, lightA), 0.0) * 0.75 + max(dot(n, lightB), 0.0) * 0.25;
    vec3 view = normalize(ro - hit.xyz);
    float spec = pow(max(dot(reflect(-lightA, n), view), 0.0), 42.0) * 0.40;
    float ao = ambientOcclusion(hit.xyz, n);

    // The distance estimate for this algebra is heuristic, so orbit-derived
    // colour would wobble with the hit point. Colour from the surface normal
    // and world position instead: stable, and it reads as material rather than
    // noise. A small orbit term keeps the fin tips distinct.
    float orbit = clamp(gHitOrbit, 0.0, 2.2);
    float height = clamp(hit.y * 0.55 + 0.5, 0.0, 1.0);
    float facing = 0.5 + 0.5 * dot(n, normalize(vec3(0.4, 0.8, 0.3)));
    float phase = fract(0.38 * height + 0.22 * facing + 0.10 * orbit
                        + 0.06 * uColorScheme);

    vec3 baseColor = palette(phase, uColorScheme);
    color = baseColor * (0.08 + diff) * (0.35 + 0.65 * ao) + vec3(spec);
    float fog = exp(-length(hit.xyz - ro) * 0.10);
    color = mix(vec3(0.018, 0.020, 0.035), color, fog);
    alpha = 1.0;
  } else {
    color = mix(vec3(0.015, 0.017, 0.030), vec3(0.045, 0.050, 0.085), uv.y * 0.5 + 0.5);
    alpha = mix(1.0, 0.0, step(0.5, uTransparentBg));
  }

  // Premultiplied alpha, matching the renderer's compositing contract.
  fragColor = vec4(linearToSRGB(color) * alpha, alpha);
}
