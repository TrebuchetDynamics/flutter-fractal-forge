#include <flutter/runtime_effect.glsl>

precision highp float;

// TORTOISE / Symbol Composer inspired toroidal fractal.
// Source study: sixfold recursive carrier tori populated by paired
// positive-chirality and negative-chirality fiber families. Rear geometry
// darkens and softens with depth, matching the reference's visual legend.

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uMousePos;
uniform float uZoom;
uniform vec3 uRotation;
uniform float uPower;
uniform float uIterations;
uniform float uSteps;
uniform float uBailout;
uniform float uColorScheme;
uniform float uFractalType;
uniform float uTransparentBg;

out vec4 fragColor;

const float PI = 3.141592653589793;

mat2 rotate2(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

vec3 rotateX(vec3 p, float angle) {
  p.yz = rotate2(angle) * p.yz;
  return p;
}

vec3 rotateY(vec3 p, float angle) {
  p.xz = rotate2(angle) * p.xz;
  return p;
}

vec3 rotateZ(vec3 p, float angle) {
  p.xy = rotate2(angle) * p.xy;
  return p;
}

float sdTorus(vec3 p, vec2 radii) {
  vec2 q = vec2(length(p.xy) - radii.x, p.z);
  return length(q) - radii.y;
}

float carrierTorus(vec3 p, float majorRadius, float tubeRadius) {
  return sdTorus(p, vec2(majorRadius, tubeRadius));
}

float mapTortoise(vec3 p) {
  float distanceToShape = carrierTorus(p, 0.92, 0.22);
  float enabledGenerations = clamp(floor(uIterations + 0.5), 1.0, 3.0);

  // Render the six parent tori explicitly so every aperture remains complete.
  // Within each parent's local frame, a sixfold space fold chooses the nearest
  // descendant: 6 explicit parents, then 36 and 216 implicit descendants.
  for (int sector = 0; sector < 6; sector++) {
    float sectorAngle = float(sector) * PI / 3.0;
    vec3 local = rotateZ(p, -sectorAngle);
    local.x -= 1.18;
    float totalScale = 0.46;
    local /= totalScale;
    float child = carrierTorus(local, 0.58, 0.12) * totalScale;
    distanceToShape = min(distanceToShape, child);

    for (int generation = 1; generation < 3; generation++) {
      if (float(generation) >= enabledGenerations) break;
      float foldedAngle = floor(
        (atan(local.y, local.x) + PI / 6.0) / (PI / 3.0)
      ) * (PI / 3.0);
      local = rotateZ(local, -foldedAngle);
      local.x -= 0.76;
      local /= 0.48;
      totalScale *= 0.48;
      float descendant = carrierTorus(local, 0.50, 0.105) * totalScale;
      distanceToShape = min(distanceToShape, descendant);
    }
  }

  return distanceToShape;
}

void nearestTorusCoordinates(
  vec3 p,
  out float theta,
  out float phi,
  out float generationDepth
) {
  float radial = length(p.xy);
  theta = atan(p.y, p.x);
  phi = atan(p.z, radial - 0.92);
  generationDepth = 0.0;
  float nearestDistance = abs(carrierTorus(p, 0.92, 0.22));
  float enabledGenerations = clamp(floor(uIterations + 0.5), 1.0, 3.0);

  for (int sector = 0; sector < 6; sector++) {
    float sectorAngle = float(sector) * PI / 3.0;
    vec3 local = rotateZ(p, -sectorAngle);
    local.x -= 1.18;
    float totalScale = 0.46;
    local /= totalScale;
    float childDistance =
        abs(carrierTorus(local, 0.58, 0.12)) * totalScale;
    if (childDistance < nearestDistance) {
      nearestDistance = childDistance;
      float childRadial = length(local.xy);
      theta = atan(local.y, local.x);
      phi = atan(local.z, childRadial - 0.58);
      generationDepth = 1.0;
    }

    for (int generation = 1; generation < 3; generation++) {
      if (float(generation) >= enabledGenerations) break;
      float foldedAngle = floor(
        (atan(local.y, local.x) + PI / 6.0) / (PI / 3.0)
      ) * (PI / 3.0);
      local = rotateZ(local, -foldedAngle);
      local.x -= 0.76;
      local /= 0.48;
      totalScale *= 0.48;
      float descendantDistance =
          abs(carrierTorus(local, 0.50, 0.105)) * totalScale;
      if (descendantDistance < nearestDistance) {
        nearestDistance = descendantDistance;
        float descendantRadial = length(local.xy);
        theta = atan(local.y, local.x);
        phi = atan(local.z, descendantRadial - 0.50);
        generationDepth = float(generation + 1);
      }
    }
  }
}

vec3 normalAt(vec3 p) {
  float e = 0.0015;
  vec2 h = vec2(e, 0.0);
  return normalize(vec3(
    mapTortoise(p + h.xyy) - mapTortoise(p - h.xyy),
    mapTortoise(p + h.yxy) - mapTortoise(p - h.yxy),
    mapTortoise(p + h.yyx) - mapTortoise(p - h.yyx)
  ));
}

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

vec3 paletteBase() {
  if (uColorScheme < 0.5) return vec3(0.34, 0.045, 0.075);
  if (uColorScheme < 1.5) return vec3(0.055, 0.035, 0.20);
  if (uColorScheme < 2.5) return vec3(0.025, 0.11, 0.13);
  return vec3(0.16, 0.055, 0.025);
}

vec3 shadeTortoise(vec3 p, vec3 normal, vec3 rayDirection, float travel) {
  float theta;
  float phi;
  float generationDepth;
  nearestTorusCoordinates(p, theta, phi, generationDepth);
  float winding = clamp(uPower, 3.0, 12.0);

  // Counter-winding fiber coordinates on the carrier torus.
  float fiberPositive = exp(-22.0 * abs(sin(winding * theta + 11.0 * phi)));
  float fiberNegative = exp(-22.0 * abs(sin(winding * theta - 11.0 * phi)));
  float beading = 0.55 + 0.45 * pow(abs(sin(18.0 * theta + 7.0 * phi)), 8.0);
  fiberPositive *= beading;
  fiberNegative *= 0.65 + 0.35 * pow(abs(cos(17.0 * theta - 5.0 * phi)), 8.0);

  vec3 lightDirection = normalize(vec3(-0.55, 0.72, 0.58));
  float diffuse = 0.28 + 0.72 * max(dot(normal, lightDirection), 0.0);
  float rim = pow(1.0 - max(dot(normal, -rayDirection), 0.0), 2.4);
  float specular = pow(max(dot(reflect(-lightDirection, normal), -rayDirection), 0.0), 38.0);
  float depthFade = exp(-0.045 * travel) * (0.82 + 0.24 * diffuse);

  vec3 burgundyCarrier = paletteBase();
  vec3 positiveGold = vec3(0.92, 0.34, 0.075);
  vec3 negativeGold = vec3(1.0, 0.78, 0.27);
  vec3 color = burgundyCarrier * (0.82 + 0.62 * diffuse) *
      (1.0 - 0.08 * generationDepth);
  color += positiveGold * fiberPositive * 1.45;
  color += negativeGold * fiberNegative * 1.75;
  color += vec3(1.0, 0.78, 0.40) * (specular * 0.95 + rim * 0.28);
  return color * depthFade;
}

void main() {
  vec2 pixel = FlutterFragCoord().xy;
  vec2 uv = (2.0 * pixel - uResolution) / max(uResolution.y, 1.0);
  uv -= uMousePos * 0.08;

  float zoom = max(uZoom, 0.05);
  vec3 camera = vec3(0.0, 0.0, 3.7 / zoom);
  vec3 rayDirection = normalize(vec3(uv, -1.75));

  // Shared raymarched uTime advances 1000 units per day. These factors yield
  // a visible ~30 second orbit and a gentler ~90 second pitch cycle.
  float drift = 0.08 * sin(uTime * 6.0);
  float yaw = uRotation.y + uTime * 18.1;
  float pitch = uRotation.x + drift;
  float roll = uRotation.z;
  camera = rotateZ(rotateY(rotateX(camera, pitch), yaw), roll);
  rayDirection = rotateZ(rotateY(rotateX(rayDirection, pitch), yaw), roll);

  float travel = 0.0;
  float glow = 0.0;
  bool hit = false;
  int maxSteps = int(clamp(uSteps, 32.0, 200.0));
  float hitEpsilon = 0.0014;
  for (int step = 0; step < 200; step++) {
    if (step >= maxSteps) break;
    vec3 point = camera + rayDirection * travel;
    float distanceToShape = mapTortoise(point);
    glow += exp(-44.0 * abs(distanceToShape)) * 0.0035;
    if (distanceToShape < hitEpsilon) {
      hit = true;
      break;
    }
    travel += max(distanceToShape * 0.72, 0.0025);
    if (travel > max(uBailout, 4.0)) break;
  }

  vec3 background = vec3(0.002, 0.001, 0.004);
  float dust = step(0.9975, hash21(floor(pixel * 0.72))) * 0.22;
  background += vec3(0.32, 0.12, 0.055) * dust;

  vec3 color = background + vec3(0.74, 0.24, 0.055) * glow;
  float alpha = uTransparentBg > 0.5 ? 0.0 : 1.0;
  if (hit) {
    vec3 point = camera + rayDirection * travel;
    vec3 normal = normalAt(point);
    color = shadeTortoise(point, normal, rayDirection, travel);
    color += vec3(1.0, 0.42, 0.08) * glow;
    alpha = 1.0;
  } else if (uTransparentBg > 0.5) {
    color = vec3(0.0);
  }

  color = 1.0 - exp(-color * 1.35);
  color = pow(max(color, vec3(0.0)), vec3(0.88));
  fragColor = vec4(color, alpha);
}
