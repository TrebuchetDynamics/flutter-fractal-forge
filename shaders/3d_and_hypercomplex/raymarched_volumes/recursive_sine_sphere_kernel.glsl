// Canonical production field/intersection kernel. Inline into both shader assets
// with scripts/sync_sine_sphere_kernel.py for Windows-portable compilation.
// The diagnostic test checks byte parity; never maintain a separate test marcher.
const int SINE_RAY_MISS = 0;
const int SINE_RAY_HIT = 1;
const int SINE_RAY_UNRESOLVED = 2;
const int SINE_RAY_TANGENT = 3;
const int SINE_RAY_STAGNATION = 4;
const float SINE_FLOAT_RESIDUAL = 0.00035;
const float SINE_BRACKET_RESIDUAL = 0.0005;

struct SineSphereIntersection {
  int status;
  float distance;
  float residual;
};

SineSphereIntersection sineSphereResult(int status, float distance, float residual) {
  SineSphereIntersection result;
  result.status = status;
  result.distance = distance;
  result.residual = residual;
  return result;
}

vec3 sineSphereWarp(vec3 point, int depth, float strength, float phase) {
  vec3 q = point;
  for (int n = 0; n < 6; ++n) {
    if (n >= depth) break;
    float frequency = exp2(float(n));
    vec3 previous = q;
    q = previous + (strength / frequency) *
        sin(frequency * previous.yzx + phase);
  }
  return q;
}

float sineSphereField(vec3 point, int depth, float strength, float radius, float phase) {
  return length(sineSphereWarp(point, depth, strength, phase)) - radius;
}

vec3 sineSphereNormal(vec3 point, int depth, float strength, float radius, float phase) {
  const float epsilon = 0.001;
  vec3 gradient = vec3(
    sineSphereField(point + vec3(epsilon, 0.0, 0.0), depth, strength, radius, phase) -
        sineSphereField(point - vec3(epsilon, 0.0, 0.0), depth, strength, radius, phase),
    sineSphereField(point + vec3(0.0, epsilon, 0.0), depth, strength, radius, phase) -
        sineSphereField(point - vec3(0.0, epsilon, 0.0), depth, strength, radius, phase),
    sineSphereField(point + vec3(0.0, 0.0, epsilon), depth, strength, radius, phase) -
        sineSphereField(point - vec3(0.0, 0.0, epsilon), depth, strength, radius, phase)
  );
  float magnitude = length(gradient);
  return magnitude > 1.0e-8 ? gradient / magnitude : vec3(0.0, 0.0, 1.0);
}

bool sineSphereEnclosureInterval(vec3 origin, vec3 direction, float bound,
                                 out float nearDistance, out float farDistance) {
  float projection = dot(origin, direction);
  float discriminant = projection * projection - dot(origin, origin) + bound * bound;
  if (isnan(discriminant) || isinf(discriminant) || discriminant < 0.0) return false;
  float root = sqrt(discriminant);
  nearDistance = -projection - root;
  farDistance = -projection + root;
  return farDistance >= 0.0;
}

SineSphereIntersection sineSphereIntersect(vec3 origin, vec3 direction,
                                           int requestedDepth, float requestedStrength,
                                           float requestedRadius, float phase,
                                           int requestedSteps) {
  if (any(isnan(origin)) || any(isinf(origin)) ||
      any(isnan(direction)) || any(isinf(direction)) ||
      isnan(phase) || isinf(phase)) {
    return sineSphereResult(SINE_RAY_UNRESOLVED, 0.0, 1.0e20);
  }
  float directionLength = length(direction);
  if (isnan(directionLength) || isinf(directionLength) || directionLength <= 0.0) {
    return sineSphereResult(SINE_RAY_UNRESOLVED, 0.0, 1.0e20);
  }
  vec3 ray = direction / directionLength;
  int depth = int(clamp(float(requestedDepth), 0.0, 6.0));
  float strength = clamp(requestedStrength, 0.0, 1.0);
  float radius = clamp(requestedRadius, 0.25, 2.0);
  int budget = int(clamp(float(requestedSteps), 1.0, 512.0));

  float nearDistance;
  float farDistance;
  if (depth == 0 || strength == 0.0) {
    if (!sineSphereEnclosureInterval(origin, ray, radius, nearDistance, farDistance)) {
      return sineSphereResult(SINE_RAY_MISS, -1.0, -1.0);
    }
    float discriminant = max(farDistance - nearDistance, 0.0);
    float distance = nearDistance >= 0.0 ? nearDistance : farDistance;
    vec3 point = origin + ray * distance;
    float residual = abs(length(point) - radius);
    if (discriminant <= 1.0e-6) {
      return sineSphereResult(SINE_RAY_TANGENT, distance, residual);
    }
    return sineSphereResult(SINE_RAY_HIT, distance, residual);
  }

  // Sum the maximum displacement magnitudes across the finite composition.
  float enclosure = radius + 1.7320508075688772 * strength *
      (2.0 * (1.0 - exp2(-float(depth))));
  if (!sineSphereEnclosureInterval(origin, ray, enclosure, nearDistance, farDistance)) {
    return sineSphereResult(SINE_RAY_MISS, -1.0, -1.0);
  }
  float distance = max(nearDistance, 0.0);
  float exitDistance = farDistance;
  float lipschitz = pow(1.0 + strength, float(depth));
  float fieldValue = sineSphereField(origin + ray * distance, depth, strength, radius, phase);
  if (isnan(fieldValue) || isinf(fieldValue)) {
    return sineSphereResult(SINE_RAY_UNRESOLVED, distance, 1.0e20);
  }
  if (abs(fieldValue) <= SINE_FLOAT_RESIDUAL) {
    vec3 point = origin + ray * distance;
    float slope = abs(
        sineSphereField(point + ray * 0.001, depth, strength, radius, phase) -
        sineSphereField(point - ray * 0.001, depth, strength, radius, phase));
    int status = slope < 0.00002 ? SINE_RAY_TANGENT : SINE_RAY_HIT;
    return sineSphereResult(status, distance, abs(fieldValue));
  }
  float previousDistance = distance;
  float previousValue = fieldValue;

  for (int stepIndex = 0; stepIndex < 512; ++stepIndex) {
    if (stepIndex >= budget || distance >= exitDistance) break;
    float advance = abs(fieldValue) / lipschitz * 0.8;
    if (isnan(advance) || isinf(advance) || advance <= 0.0) {
      return sineSphereResult(advance <= 0.0 ? SINE_RAY_STAGNATION : SINE_RAY_UNRESOLVED,
                              distance, abs(fieldValue));
    }
    previousDistance = distance;
    previousValue = fieldValue;
    float nextDistance = min(distance + advance, exitDistance);
    float nextValue = sineSphereField(origin + ray * nextDistance,
                                      depth, strength, radius, phase);
    if (isnan(nextValue) || isinf(nextValue)) {
      return sineSphereResult(SINE_RAY_UNRESOLVED, nextDistance, 1.0e20);
    }

    if ((nextValue < 0.0) != (previousValue < 0.0)) {
      float low = previousDistance;
      float high = nextDistance;
      float lowValue = previousValue;
      for (int refinement = 0; refinement < 24; ++refinement) {
        float middle = 0.5 * (low + high);
        float middleValue = sineSphereField(origin + ray * middle,
                                            depth, strength, radius, phase);
        if ((middleValue < 0.0) == (lowValue < 0.0)) {
          low = middle;
          lowValue = middleValue;
        } else {
          high = middle;
        }
      }
      float hitDistance = 0.5 * (low + high);
      float residual = abs(sineSphereField(origin + ray * hitDistance,
                                           depth, strength, radius, phase));
      return residual <= SINE_BRACKET_RESIDUAL
          ? sineSphereResult(SINE_RAY_HIT, hitDistance, residual)
          : sineSphereResult(SINE_RAY_UNRESOLVED, hitDistance, residual);
    }

    if (abs(nextValue) <= SINE_FLOAT_RESIDUAL) {
      vec3 point = origin + ray * nextDistance;
      float slope = abs(
          sineSphereField(point + ray * 0.001, depth, strength, radius, phase) -
          sineSphereField(point - ray * 0.001, depth, strength, radius, phase));
      int status = slope < 0.00002 ? SINE_RAY_TANGENT : SINE_RAY_HIT;
      return sineSphereResult(status, nextDistance, abs(nextValue));
    }
    if (nextDistance <= distance) {
      return sineSphereResult(SINE_RAY_STAGNATION, distance, abs(fieldValue));
    }
    if (nextDistance >= exitDistance) {
      return sineSphereResult(SINE_RAY_MISS, -1.0, -1.0);
    }
    distance = nextDistance;
    fieldValue = nextValue;
  }
  return sineSphereResult(SINE_RAY_UNRESOLVED, distance, abs(fieldValue));
}
