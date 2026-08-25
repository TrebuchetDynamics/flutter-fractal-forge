#include <flutter/runtime_effect.glsl>

precision highp float;

// Five original, sampler-free recursive objects. The common visual grammar is
// intentionally simple: one mathematical sculpture, slow object-space motion,
// dense analytic detail, an emissive near-miss halo, and genuine black space.
// No preset, feedback texture, waveform, FFT, media frame, or external asset is
// sampled. Identity is fixed by the catalog through uFractalType.
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uMousePos;      // 3-4
uniform float uZoom;          // 5
uniform vec3  uRotation;      // 6-8
uniform float uPower;         // 9: identity-specific scale/order
uniform float uIterations;    // 10: recursive depth
uniform float uSteps;         // 11: sphere-tracing budget
uniform float uBailout;       // 12: march reach and halo response
uniform float uColorScheme;   // 13
uniform float uFractalType;   // 14: 0 Cayley, 1 gyroid, 2 Mobius, 3 Fibonacci, 4 Chebyshev
uniform float uTransparentBg; // 15

out vec4 fragColor;

const float PI = 3.14159265358979323846;
const float TAU = 6.28318530717958647692;
const float GOLDEN_ANGLE = 2.39996322972865332;

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
  float s = floor(clamp(scheme, 0.0, 3.0));
  vec3 offset = vec3(0.56, 0.12, 0.86);
  vec3 frequency = vec3(1.00, 0.82, 1.18);
  if (s > 0.5 && s < 1.5) {
    offset = vec3(0.31, 0.78, 0.06);
    frequency = vec3(0.82, 1.07, 0.91);
  } else if (s > 1.5 && s < 2.5) {
    offset = vec3(0.91, 0.22, 0.49);
    frequency = vec3(1.13, 0.89, 1.02);
  } else if (s > 2.5) {
    offset = vec3(0.08, 0.48, 0.92);
    frequency = vec3(0.90, 1.19, 0.77);
  }
  return clamp(0.48 + 0.52 * cos(TAU * (frequency * phase + offset)), 0.0, 1.0);
}

float sdCapsule(vec3 point, vec3 a, vec3 b, float radius) {
  vec3 pa = point - a;
  vec3 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-5), 0.0, 1.0);
  return length(pa - ba * h) - radius;
}

// Threefold graph-directed capsule IFS. Folding the azimuth into one sector
// represents all 3^depth branches in O(depth), without enumerating children.
float ternaryCayleyDistance(vec3 point, out float orbit) {
  int depth = int(clamp(floor(uIterations + 0.5), 2.0, 6.0));
  float childScale = clamp(uPower, 0.48, 0.70);
  float branchAngle = 0.95;
  float worldScale = 1.0;
  float distanceValue = 1e4;
  vec3 q = point;
  orbit = 10.0;

  for (int generation = 0; generation < 6; generation++) {
    if (generation >= depth) break;
    float generationPhase = float(generation) / max(float(depth - 1), 1.0);
    float radius = mix(0.105, 0.038, generationPhase);
    float branch = sdCapsule(
      q,
      vec3(0.0, -0.58, 0.0),
      vec3(0.0, 0.43, 0.0),
      radius
    );
    distanceValue = min(distanceValue, branch * worldScale);
    orbit = min(orbit, length(q.xz) + 0.18 * abs(q.y));

    q.y -= 0.43;
    float azimuth = atan(q.z, q.x);
    float sector = TAU / 3.0;
    float folded = mod(azimuth + 0.5 * sector, sector) - 0.5 * sector;
    float radial = length(q.xz);
    float radialAlong = radial * cos(folded);
    float tangent = radial * sin(folded);
    vec2 aligned = rotate2d(branchAngle) * vec2(radialAlong, q.y);
    q = vec3(aligned.x, aligned.y, tangent) / childScale;
    worldScale *= childScale;
  }
  return distanceValue;
}

float gyroidField(vec3 point) {
  return sin(point.x) * cos(point.y) +
      sin(point.y) * cos(point.z) +
      sin(point.z) * cos(point.x);
}

// A finite recursive union of increasingly fine gyroid membranes, clipped to
// a sphere. The gradient denominator is a conservative analytic bound.
float gyroidReliquaryDistance(vec3 point, out float orbit) {
  int depth = int(clamp(floor(uIterations + 0.5), 1.0, 4.0));
  float baseFrequency = clamp(uPower, 1.6, 3.4);
  float frequency = baseFrequency;
  vec3 q = point * baseFrequency;
  float distanceValue = 1e4;
  orbit = 10.0;

  mat3 octaveTurn = rotationMatrix(vec3(0.37, 0.53, 0.29));
  for (int level = 0; level < 4; level++) {
    if (level >= depth) break;
    float field = gyroidField(q);
    float thickness = 0.24 * pow(0.78, float(level));
    float shell = (abs(field) - thickness) / max(1.78 * frequency, 1e-4);
    distanceValue = min(distanceValue, shell);
    orbit = min(orbit, abs(field) / (1.0 + float(level)));
    q = octaveTurn * q * 1.72 + vec3(0.41, -0.27, 0.33);
    frequency *= 1.72;
  }

  return max(distanceValue, length(point) - 1.08);
}

float mobiusBandDistance(vec3 point, float radius, float halfWidth, float halfThickness, out float bandCoordinate) {
  float theta = atan(point.z, point.x);
  float radial = length(point.xz) - radius;
  float c = cos(0.5 * theta);
  float s = sin(0.5 * theta);
  float across = point.y * c + radial * s;
  float normal = -point.y * s + radial * c;
  bandCoordinate = abs(across) + 2.0 * abs(normal);
  return max(abs(across) - halfWidth, abs(normal) - halfThickness);
}

// Nested similarity copies of a one-sided Mobius ribbon. Each level retains
// the half-twist while an irrational echo rotation avoids coincident seams.
float mobiusEchoDistance(vec3 point, out float orbit) {
  int depth = int(clamp(floor(uIterations + 0.5), 1.0, 5.0));
  float echoScale = clamp(uPower, 0.45, 0.72);
  float worldScale = 1.0;
  float distanceValue = 1e4;
  orbit = 10.0;

  for (int level = 0; level < 5; level++) {
    if (level >= depth) break;
    vec3 q = rotationMatrix(vec3(0.31 * float(level), 0.77 * float(level), 0.0)) * point;
    q /= max(worldScale, 1e-5);
    float bandCoordinate;
    float local = mobiusBandDistance(q, 0.72, 0.245, 0.042, bandCoordinate);
    distanceValue = min(distanceValue, local * worldScale);
    orbit = min(orbit, bandCoordinate * worldScale);
    worldScale *= echoScale;
  }
  return distanceValue;
}

vec3 fibonacciDirection(int index) {
  float count = 12.0;
  float i = float(index);
  float y = 1.0 - 2.0 * (i + 0.5) / count;
  float radius = sqrt(max(0.0, 1.0 - y * y));
  float angle = i * GOLDEN_ANGLE;
  return vec3(radius * cos(angle), y, radius * sin(angle));
}

vec3 toDirectionFrame(vec3 point, vec3 direction) {
  vec3 helper = abs(direction.y) < 0.92 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
  vec3 right = normalize(cross(helper, direction));
  vec3 forward = cross(direction, right);
  return vec3(dot(point, right), dot(point, direction), dot(point, forward));
}

float cappedConeBudDistance(vec3 point) {
  const float halfHeight = 0.46;
  float t = clamp((point.y + halfHeight) / (2.0 * halfHeight), 0.0, 1.0);
  float radius = mix(0.245, 0.035, t);
  float side = length(point.xz) - radius;
  float cap = abs(point.y) - halfHeight;
  return max(side, cap) * 0.72;
}

// A twelve-map graph-directed IFS whose child axes follow a spherical
// Fibonacci lattice. The terminal primitive is a tapered cone rather than a
// sphere, preserving the directed Romanesco-like botanical identity.
float fibonacciConeDistance(vec3 point, out float orbit) {
  int depth = int(clamp(floor(uIterations + 0.5), 1.0, 4.0));
  float childScale = clamp(uPower, 0.28, 0.48);
  float worldScale = 1.0;
  float distanceValue = 1e4;
  vec3 q = point;
  orbit = 10.0;

  for (int level = 0; level < 4; level++) {
    if (level >= depth) break;
    float best = 1e4;
    vec3 selected = q;
    for (int child = 0; child < 12; child++) {
      vec3 direction = fibonacciDirection(child);
      vec3 center = direction * (0.76 * (1.0 - childScale));
      vec3 relative = q - center;
      vec3 candidate = toDirectionFrame(relative, direction) / childScale;
      float metric = cappedConeBudDistance(candidate);
      if (metric < best) {
        best = metric;
        selected = candidate;
      }
    }
    q = selected;
    worldScale *= childScale;
    distanceValue = min(distanceValue, best * worldScale);
    orbit = min(orbit, abs(best) * worldScale);
  }
  return distanceValue;
}

float chebyshevT(float value, int order) {
  float t0 = 1.0;
  float t1 = value;
  if (order <= 0) return t0;
  if (order == 1) return t1;
  for (int index = 2; index <= 24; index++) {
    if (index > order) break;
    float next = 2.0 * value * t1 - t0;
    t0 = t1;
    t1 = next;
  }
  return t1;
}

float blendedChebyshev(float value, float orderValue) {
  float clampedOrder = clamp(orderValue, 2.0, 23.99);
  int lower = int(floor(clampedOrder));
  int upper = lower + 1;
  float blend = fract(clampedOrder);
  return mix(chebyshevT(value, lower), chebyshevT(value, upper), blend);
}

// Nodal sheets generated by Chebyshev recurrences and exact frequency
// doubling. Fractional base order blends adjacent polynomials, so every 0.1
// step exposed by the shared 3D builder remains visually active.
float chebyshevLanternDistance(vec3 point, out float orbit) {
  int depth = int(clamp(floor(uIterations + 0.5), 1.0, 3.0));
  float baseOrder = clamp(uPower, 2.0, 5.9);
  float distanceValue = 1e4;
  orbit = 10.0;

  for (int level = 0; level < 3; level++) {
    if (level >= depth) break;
    float orderValue = min(baseOrder * pow(2.0, float(level)), 23.99);
    vec3 q = rotationMatrix(vec3(0.29 * float(level), 0.41 * float(level), 0.17 * float(level))) * point;
    q *= 0.88;
    float tx = blendedChebyshev(q.x, orderValue);
    float ty = blendedChebyshev(q.y, orderValue);
    float tz = blendedChebyshev(q.z, orderValue);
    float field = tx * ty + ty * tz + tz * tx - 0.16;
    float gradientBound = 3.5 * orderValue * orderValue;
    float thickness = 0.12 * pow(0.74, float(level));
    float sheet = (abs(field) - thickness) / max(gradientBound, 1.0);
    distanceValue = min(distanceValue, sheet);
    orbit = min(orbit, abs(field) / (1.0 + float(level)));
  }
  return max(distanceValue, length(point) - 1.04);
}

float objectDistance(vec3 point, out float orbit) {
  float spin = uTime * 3.2;
  mat3 automaticTurn = rotationMatrix(vec3(
    0.22 * sin(spin * 0.31),
    spin * 0.61,
    spin * 0.23
  ));
  vec3 q = automaticTurn * point;
  int construction = int(clamp(floor(uFractalType + 0.5), 0.0, 4.0));
  if (construction == 1) return gyroidReliquaryDistance(q, orbit);
  if (construction == 2) return mobiusEchoDistance(q, orbit);
  if (construction == 3) return fibonacciConeDistance(q, orbit);
  if (construction == 4) return chebyshevLanternDistance(q, orbit);
  return ternaryCayleyDistance(q, orbit);
}

float distanceOnly(vec3 point) {
  float orbit;
  return objectDistance(point, orbit);
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
  uv -= uMousePos * 0.55;

  mat3 cameraTurn = rotationMatrix(uRotation);
  vec3 origin = cameraTurn * vec3(0.0, 0.0, 3.25 / max(uZoom, 0.25));
  vec3 direction = normalize(cameraTurn * vec3(uv, -1.55));

  vec2 interval;
  bool intersectsBounds = sphereInterval(origin, direction, 1.36, interval);
  int maxSteps = int(clamp(floor(uSteps + 0.5), 20.0, 200.0));
  float hitThreshold = max(0.00135 / max(uZoom, 0.25), 1e-5);
  float travelled = intersectsBounds ? interval.x : 0.0;
  float endDistance = intersectsBounds
      ? min(interval.y, interval.x + max(uBailout, 1.0) * 1.45)
      : 0.0;
  float hitStep = -1.0;
  float hitOrbit = 0.0;
  float closest = 10.0;
  float emission = 0.0;
  vec3 samplePoint = origin;

  if (intersectsBounds) {
    for (int stepIndex = 0; stepIndex < 200; stepIndex++) {
      if (stepIndex >= maxSteps) break;
      samplePoint = origin + direction * travelled;
      float orbit;
      float distanceValue = objectDistance(samplePoint, orbit);
      float absoluteDistance = abs(distanceValue);
      closest = min(closest, absoluteDistance);
      emission += exp(-absoluteDistance * (18.0 + 2.0 * uBailout)) * 0.018;
      if (distanceValue < hitThreshold) {
        hitStep = float(stepIndex);
        hitOrbit = orbit;
        break;
      }
      travelled += max(distanceValue * 0.58, hitThreshold * 0.45);
      if (travelled > endDistance) break;
    }
  }

  vec3 color = vec3(0.0);
  float alpha = 1.0;
  if (hitStep >= 0.0) {
    vec3 normal = surfaceNormal(samplePoint);
    vec3 lightDirection = normalize(vec3(0.72, 0.91, 0.54));
    vec3 viewDirection = safeNormalize(origin - samplePoint, -direction);
    vec3 halfDirection = safeNormalize(lightDirection + viewDirection, lightDirection);
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float rim = pow(1.0 - max(dot(normal, viewDirection), 0.0), 2.2);
    float specular = pow(max(dot(normal, halfDirection), 0.0), 54.0);
    float phase = hitOrbit * 1.9 + 0.10 * length(samplePoint) + hitStep / max(uSteps, 1.0);
    vec3 base = palette(phase, uColorScheme);
    float sparkle = pow(
      max(0.0, 0.5 + 0.5 * sin(hitOrbit * 93.0 + dot(samplePoint, vec3(31.0, 37.0, 43.0)))),
      14.0
    );
    color = base * (0.10 + 0.78 * diffuse);
    color += palette(phase + 0.31, uColorScheme) * rim * 0.72;
    color += vec3(1.0, 0.94, 0.82) * (0.48 * specular + 0.62 * sparkle);
  } else if (intersectsBounds) {
    float halo = clamp(
      emission * (0.72 + 0.10 * uBailout) + exp(-closest * 11.0) * 0.16,
      0.0,
      0.72
    );
    color = palette(0.11 + closest * 0.35, uColorScheme) * halo;
  }

  color = linearToSRGB(clamp(color, 0.0, 1.0));
  if (uTransparentBg > 0.5 && hitStep < 0.0) {
    float brightness = max(color.r, max(color.g, color.b));
    alpha = smoothstep(0.018, 0.20, brightness);
    color *= alpha;
  }
  fragColor = vec4(color, alpha);
}
