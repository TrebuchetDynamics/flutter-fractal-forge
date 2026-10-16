#include <flutter/runtime_effect.glsl>

precision highp float;

// Bounded, seeded 3D particle-attachment approximation rendered as an SDF.
uniform float uTime; // 0
uniform vec2 uResolution; // 1-2
uniform vec2 uMousePos; // 3-4
uniform float uZoom; // 5
uniform vec3 uRotation; // 6-8
uniform float uPower; // 9
uniform float uIterations; // 10
uniform float uSteps; // 11
uniform float uBailout; // 12
uniform float uColorScheme; // 13
uniform float uFractalType; // 14
uniform float uTransparentBg; // 15
uniform float uSeed; // 16

out vec4 fragColor;

float hash(float n) {
  return fract(sin((n + uSeed * 17.71) * 127.1 + 311.7) * 43758.5453123);
}

float segmentDistance(vec3 p, vec3 a, vec3 b) {
  vec3 pa = p - a;
  vec3 ba = b - a;
  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.0001), 0.0, 1.0);
  return length(pa - ba * h);
}

mat3 rotationMatrix(vec3 angles) {
  float cx = cos(angles.x), sx = sin(angles.x);
  float cy = cos(angles.y), sy = sin(angles.y);
  float cz = cos(angles.z), sz = sin(angles.z);
  return mat3(
    cy * cz, sx * sy * cz - cx * sz, cx * sy * cz + sx * sz,
    cy * sz, sx * sy * sz + cx * cz, cx * sy * sz - sx * cz,
    -sy, sx * cy, cx * cy
  );
}

vec3 randomDirection3D(float n) {
  float z = 2.0 * hash(n + 37.0) - 1.0;
  float angle = 6.2831853 * hash(n + 71.0);
  float radius = sqrt(max(0.0, 1.0 - z * z));
  return vec3(radius * cos(angle), radius * sin(angle), z);
}

vec3 particlePosition3D(int particleId) {
  if (particleId == 0) return vec3(0.0);
  int node = particleId + 1;
  int cursor = node;
  int depth = 0;
  for (int i = 0; i < 6; i++) {
    if (cursor <= 1) break;
    cursor = (cursor - 2) / 3 + 1;
    depth++;
  }

  vec3 position = vec3(0.0);
  float spread = clamp(uPower, 0.65, 2.2);
  for (int level = 0; level < 6; level++) {
    if (level >= depth) break;
    int childNode = node;
    for (int climb = 0; climb < 6; climb++) {
      if (climb >= depth - level - 1) break;
      childNode = (childNode - 2) / 3 + 1;
    }
    vec3 randomStep = randomDirection3D(float(childNode) * 13.0 + float(level));
    vec3 radial = dot(position, position) > 0.0001 ? normalize(position) :
        randomStep;
    vec3 drift = normalize(randomStep * 0.82 + radial * 0.42);
    float spacing = (0.13 + 0.14 * hash(float(childNode) + 29.0)) *
        (1.0 - 0.06 * float(level)) * spread;
    position += drift * spacing;
  }
  return position;
}

float coralDistance(vec3 p, int pointCount, out float age) {
  float spread = clamp(uPower, 0.65, 2.2);
  float distanceValue = length(p - particlePosition3D(0)) - 0.04 * spread;
  age = 0.0;
  for (int i = 1; i < 64; i++) {
    if (i >= pointCount) break;
    float fi = float(i);
    vec3 point = particlePosition3D(i);
    vec3 parent = particlePosition3D((i - 1) / 3);
    float radius = 0.018 * spread * (1.0 - 0.18 * fi / float(pointCount));
    float local = min(
      length(p - point) - radius,
      segmentDistance(p, parent, point) - 0.024 * spread
    );
    if (local < distanceValue) {
      distanceValue = local;
      age = fi / float(pointCount);
    }
  }
  return distanceValue;
}

vec3 surfaceNormal(vec3 p, int pointCount) {
  const float epsilon = 0.0015;
  vec2 e = vec2(1.0, -1.0) * epsilon;
  float unusedAge;
  return normalize(
    e.xyy * coralDistance(p + e.xyy, pointCount, unusedAge) +
    e.yyx * coralDistance(p + e.yyx, pointCount, unusedAge) +
    e.yxy * coralDistance(p + e.yxy, pointCount, unusedAge) +
    e.xxx * coralDistance(p + e.xxx, pointCount, unusedAge)
  );
}

vec3 coralPalette(float phase) {
  float scheme = mod(floor(uColorScheme), 4.0);
  vec3 deep = vec3(0.26, 0.045, 0.035);
  vec3 coral = vec3(0.78, 0.19, 0.11);
  vec3 tip = vec3(1.0, 0.68, 0.38);
  if (scheme > 0.5 && scheme < 1.5) {
    deep = vec3(0.025, 0.10, 0.16);
    coral = vec3(0.08, 0.53, 0.63);
    tip = vec3(0.63, 0.91, 0.88);
  } else if (scheme > 1.5 && scheme < 2.5) {
    deep = vec3(0.13, 0.045, 0.16);
    coral = vec3(0.57, 0.19, 0.54);
    tip = vec3(0.94, 0.68, 0.82);
  } else if (scheme > 2.5) {
    deep = vec3(0.12, 0.09, 0.025);
    coral = vec3(0.63, 0.39, 0.08);
    tip = vec3(0.98, 0.86, 0.49);
  }
  float t = clamp(phase, 0.0, 1.0);
  return mix(mix(deep, coral, smoothstep(0.0, 0.78, t)), tip,
      smoothstep(0.72, 1.0, t));
}

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

void main() {
  // Seeded three-way branching keeps the shader bounded on mobile GPUs.
  int pointCount = int(clamp(uIterations * 2.4, 12.0, 56.0));
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;
  mat3 rotation = rotationMatrix(uRotation);
  vec3 target = vec3(uMousePos, 0.0);
  float zoom = max(uZoom, 0.2);
  vec3 origin = target + rotation * vec3(0.0, 0.0, -2.5 / zoom);
  vec3 direction = normalize(rotation * vec3(uv, 1.55));
  int maxSteps = int(clamp(uSteps, 24.0, 128.0));
  float travelled = 0.0;
  float hit = -1.0;
  float hitAge = 0.0;
  vec3 position = origin;

  for (int stepIndex = 0; stepIndex < 128; stepIndex++) {
    if (stepIndex >= maxSteps) break;
    position = origin + direction * travelled;
    float age = 0.0;
    float distanceValue = coralDistance(position, pointCount, age);
    if (distanceValue < 0.0015 / zoom) {
      hit = float(stepIndex);
      hitAge = age;
      break;
    }
    travelled += max(distanceValue * 0.72, 0.001);
    if (travelled > max(uBailout, 6.0)) break;
  }

  if (hit < 0.0) {
    vec3 background = vec3(0.004, 0.006, 0.009);
    fragColor = uTransparentBg > 0.5
        ? vec4(0.0)
        : vec4(linearToSRGB(background), 1.0);
    return;
  }

  vec3 normal = surfaceNormal(position, pointCount);
  vec3 lightDirection = normalize(vec3(-0.4, 0.7, -0.55));
  float diffuse = max(dot(normal, lightDirection), 0.0);
  float rim = pow(1.0 - max(dot(normal, -direction), 0.0), 2.0);
  float phase = fract(hitAge + length(position) * 0.4 + uSeed * 0.0001);
  vec3 color = coralPalette(phase) * (0.22 + 0.78 * diffuse) +
      vec3(1.0, 0.45, 0.24) * rim * 0.15;
  fragColor = vec4(linearToSRGB(color), 1.0);
}
