#include <flutter/runtime_effect.glsl>

precision highp float;

// Luminous Fold Lattice — an original, clean-room, sampler-free glowmarcher.
// The recurrence, constants, palette, camera, and timing were authored for
// Fractal Forge. No third-party shader source or media is copied or translated.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uMousePos;      // 3-4: shared camera target
uniform float uZoom;          // 5
uniform vec3  uRotation;      // 6-8
uniform float uPower;         // 9: fold scale
uniform float uIterations;    // 10: recursive depth
uniform float uSteps;         // 11: sphere-tracing budget
uniform float uBailout;       // 12: march reach and halo response
uniform float uColorScheme;   // 13
uniform float uFractalType;   // 14: reserved by the shared ABI
uniform float uTransparentBg; // 15

out vec4 fragColor;

const float TAU = 6.28318530717958647692;

mat2 rotate2d(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
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

vec3 safeNormalize(vec3 value, vec3 fallback) {
  float magnitudeSquared = dot(value, value);
  return magnitudeSquared > 1e-12
      ? value * inversesqrt(magnitudeSquared)
      : fallback;
}

vec3 linearToSRGB(vec3 value) {
  value = clamp(value, 0.0, 1.0);
  bvec3 cutoff = lessThan(value, vec3(0.0031308));
  vec3 high = 1.055 * pow(max(value, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 low = value * 12.92;
  return mix(high, low, vec3(cutoff));
}

vec3 palette(float phase, float scheme) {
  float selected = floor(clamp(scheme, 0.0, 3.0));
  vec3 offset = vec3(0.12, 0.42, 0.78);
  vec3 rate = vec3(1.00, 0.83, 1.17);
  if (selected > 0.5 && selected < 1.5) {
    offset = vec3(0.91, 0.48, 0.08);
    rate = vec3(0.91, 1.08, 0.79);
  } else if (selected > 1.5 && selected < 2.5) {
    offset = vec3(0.58, 0.04, 0.32);
    rate = vec3(1.14, 0.88, 1.02);
  } else if (selected > 2.5) {
    offset = vec3(0.02, 0.68, 0.40);
    rate = vec3(0.82, 1.19, 0.96);
  }
  return clamp(0.48 + 0.52 * cos(TAU * (offset + rate * phase)), 0.0, 1.0);
}

float roundedOctahedron(vec3 point, float radius, float rounding) {
  return (dot(abs(point), vec3(0.577350269)) - radius) - rounding;
}

// Reflection/ordering folds reduce the point into one symmetry chamber. An
// irrational fixed rotation and alternating twist prevent a separable grid.
// The inverse accumulated scale maps the terminal primitive back to world space.
float latticeDistance(vec3 point, out float orbit) {
  int depth = int(clamp(floor(uIterations + 0.5), 2.0, 9.0));
  float scale = clamp(uPower, 1.45, 2.80);
  float inverseScale = 1.0;
  vec3 q = rotationMatrix(vec3(0.391, -0.617, 0.233)) * point;
  orbit = 8.0;

  for (int level = 0; level < 9; level++) {
    if (level >= depth) break;
    q = abs(q);
    if (q.x < q.y) q.xy = q.yx;
    if (q.x < q.z) q.xz = q.zx;
    if (q.y < q.z) q.yz = q.zy;

    float alternating = mod(float(level), 2.0) * 2.0 - 1.0;
    q.xy = rotate2d(alternating * (0.071 + 0.013 * float(level))) * q.xy;
    q = scale * q - vec3(0.82, 0.67, 0.91) * (scale - 1.0);
    inverseScale /= scale;

    float edgeTrap = min(length(q.xy), min(length(q.yz), length(q.zx)));
    float chamberTrap = abs(q.x - q.y) + 0.5 * abs(q.y - q.z);
    orbit = min(orbit, min(edgeTrap * 0.52, chamberTrap) * inverseScale);
  }

  float terminal = roundedOctahedron(q, 0.46, 0.035);
  float cross = min(length(q.xy), min(length(q.yz), length(q.zx))) - 0.055;
  return min(terminal, cross) * inverseScale;
}

float distanceOnly(vec3 point) {
  float orbit;
  return latticeDistance(point, orbit);
}

vec3 surfaceNormal(vec3 point) {
  float epsilon = max(0.0014 / max(uZoom, 0.25), 1e-5);
  vec2 e = vec2(1.0, -1.0) * epsilon;
  vec3 gradient =
      e.xyy * distanceOnly(point + e.xyy) +
      e.yyx * distanceOnly(point + e.yyx) +
      e.yxy * distanceOnly(point + e.yxy) +
      e.xxx * distanceOnly(point + e.xxx);
  return safeNormalize(gradient, vec3(0.0, 1.0, 0.0));
}

bool sphereInterval(vec3 origin, vec3 direction, float radius, out vec2 interval) {
  float projection = dot(origin, direction);
  float discriminant = projection * projection - dot(origin, origin) + radius * radius;
  if (discriminant < 0.0) return false;
  float root = sqrt(discriminant);
  interval = vec2(max(0.0, -projection - root), -projection + root);
  return interval.y > interval.x;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / max(uResolution.y, 1.0);

  float motion = uTime * 4.8;
  mat3 cameraTurn = rotationMatrix(uRotation);
  vec3 target = vec3(uMousePos * 0.55, 0.0);
  vec3 origin = target + cameraTurn * vec3(0.0, 0.0, 3.35 / max(uZoom, 0.25));
  vec3 direction = normalize(cameraTurn * vec3(uv, -1.58));
  mat3 objectTurn = rotationMatrix(vec3(
    0.14 * sin(motion * 0.23),
    motion * 0.37,
    0.11 * cos(motion * 0.19)
  ));

  vec2 interval;
  bool intersectsBounds = sphereInterval(origin - target, direction, 1.42, interval);
  int maxSteps = int(clamp(floor(uSteps + 0.5), 20.0, 180.0));
  float threshold = max(0.00125 / max(uZoom, 0.25), 1e-5);
  float travelled = intersectsBounds ? interval.x : 0.0;
  float endDistance = intersectsBounds
      ? min(interval.y, interval.x + max(uBailout, 1.0) * 1.35)
      : 0.0;
  float hitStep = -1.0;
  float hitOrbit = 0.0;
  float closest = 8.0;
  float emission = 0.0;
  vec3 samplePoint = vec3(0.0);

  if (intersectsBounds) {
    for (int stepIndex = 0; stepIndex < 180; stepIndex++) {
      if (stepIndex >= maxSteps) break;
      vec3 worldPoint = origin + direction * travelled - target;
      samplePoint = objectTurn * worldPoint;
      float orbit;
      float distanceValue = latticeDistance(samplePoint, orbit);
      float absoluteDistance = abs(distanceValue);
      closest = min(closest, absoluteDistance);
      float haloFalloff = 20.0 + 2.4 * clamp(uBailout, 1.0, 8.0);
      emission += exp(-absoluteDistance * haloFalloff) * (0.016 + 0.0015 * uBailout);
      if (distanceValue < threshold) {
        hitStep = float(stepIndex);
        hitOrbit = orbit;
        break;
      }
      travelled += max(distanceValue * 0.61, threshold * 0.48);
      if (travelled > endDistance) break;
    }
  }

  vec3 color = vec3(0.0);
  float alpha = 1.0;
  if (hitStep >= 0.0) {
    vec3 normal = surfaceNormal(samplePoint);
    vec3 lightDirection = normalize(vec3(0.64, 0.88, 0.51));
    vec3 viewDirection = safeNormalize(objectTurn * (origin - target) - samplePoint, -direction);
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float rim = pow(1.0 - max(dot(normal, viewDirection), 0.0), 2.1);
    float phase = hitOrbit * 2.3 + hitStep / max(uSteps, 1.0) + motion * 0.018;
    vec3 base = palette(phase, uColorScheme);
    color = base * (0.08 + 0.64 * diffuse);
    color += palette(phase + 0.29, uColorScheme) * (0.72 * rim + emission * 0.72);
  } else if (intersectsBounds) {
    float halo = clamp(
      emission * (0.86 + 0.08 * uBailout) + exp(-closest * 13.0) * 0.13,
      0.0,
      0.84
    );
    color = palette(0.16 + closest * 0.41 + motion * 0.014, uColorScheme) * halo;
  }

  color = 1.0 - exp(-color * 1.32);
  color = linearToSRGB(clamp(color, 0.0, 1.0));
  if (uTransparentBg > 0.5 && hitStep < 0.0) {
    alpha = smoothstep(0.010, 0.22, max(color.r, max(color.g, color.b)));
    color *= alpha;
  }
  fragColor = vec4(color, alpha);
}
