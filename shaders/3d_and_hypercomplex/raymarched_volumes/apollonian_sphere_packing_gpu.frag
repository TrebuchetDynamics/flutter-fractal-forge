#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;
uniform vec2  uResolution;
uniform vec2  uMousePos;
uniform float uZoom;
uniform vec3  uRotation;
uniform float uPower;
uniform float uIterations;
uniform float uSteps;
uniform float uBailout;
uniform float uColorScheme;
uniform float uFractalType;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
  lin = clamp(lin, 0.0, 1.0);
  bvec3 cutoff = lessThan(lin, vec3(0.0031308));
  vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
  vec3 lo = lin * 12.92;
  return mix(hi, lo, vec3(cutoff));
}

mat3 rotationMatrix(vec3 a) {
  float cx = cos(a.x), sx = sin(a.x);
  float cy = cos(a.y), sy = sin(a.y);
  float cz = cos(a.z), sz = sin(a.z);
  return mat3(
    cy * cz, sx * sy * cz - cx * sz, cx * sy * cz + sx * sz,
    cy * sz, sx * sy * sz + cx * cz, cx * sy * sz - sx * cz,
    -sy,     sx * cy,                cx * cy
  );
}

vec3 palette(float t, float scheme) {
  float s = mod(scheme, 8.0);
  vec3 a = vec3(0.5);
  vec3 b = vec3(0.5);
  vec3 c = vec3(1.0);
  vec3 d = vec3(0.00, 0.33, 0.67);
  if (s < 1.0) { a = vec3(0.45, 0.20, 0.05); b = vec3(0.45, 0.30, 0.12); c = vec3(1.0, 0.75, 0.35); d = vec3(0.0, 0.16, 0.28); }
  else if (s < 2.0) { a = vec3(0.05, 0.18, 0.32); b = vec3(0.15, 0.30, 0.40); c = vec3(0.8, 0.9, 1.0); d = vec3(0.0, 0.12, 0.27); }
  else if (s < 3.0) { a = vec3(0.08, 0.06, 0.22); b = vec3(0.38, 0.22, 0.48); c = vec3(1.0, 0.8, 0.6); d = vec3(0.58, 0.22, 0.08); }
  else if (s < 4.0) { a = vec3(0.46); b = vec3(0.42); c = vec3(1.0); d = vec3(0.0); }
  return a + b * cos(6.28318 * (c * t + d));
}

vec3 sortAbs(vec3 p) {
  p = abs(p);
  if (p.x < p.y) p.xy = p.yx;
  if (p.x < p.z) p.xz = p.zx;
  if (p.y < p.z) p.yz = p.zy;
  return p;
}

float apollonianDE(vec3 pos) {
  vec3 p = pos;
  float scale = 1.0;
  float d = length(p) - 1.18;
  float foldScale = clamp(uPower, 1.35, 2.85);
  int maxIter = int(clamp(uIterations, 3.0, 32.0));
  int variant = int(mod(uFractalType, 4.0));

  for (int i = 0; i < 32; i++) {
    if (i >= maxIter) break;

    if (variant == 0) {
      p = sortAbs(p);
      p = p * foldScale - vec3(foldScale - 1.0, foldScale - 1.0, foldScale - 1.0);
    } else if (variant == 1) {
      p = abs(p);
      p.xy = mat2(0.8660254, -0.5, 0.5, 0.8660254) * p.xy;
      p = p * foldScale - vec3(0.78, 0.78, 0.58) * (foldScale - 1.0);
    } else if (variant == 2) {
      p = abs(p) * foldScale - vec3(0.95, 0.55, 0.95) * (foldScale - 1.0);
    } else {
      p = sortAbs(p + 0.08 * sin(uTime * 0.00025 + float(i)));
      p = p * foldScale - vec3(0.66, 0.92, 0.78) * (foldScale - 1.0);
    }

    float r2 = max(dot(p, p), 0.0005);
    float k = clamp(1.15 / r2, 0.55, 2.6);
    p *= k;
    scale *= abs(foldScale * k);

    // The repeated small sphere is what creates the Apollonian bubbles.
    float sphere = (length(p) - 0.36) / max(scale, 1e-5);
    d = min(d, sphere);
  }

  // Keep the estimator positive enough for stable marching.
  return max(d, 0.0007);
}

float apollonianColor(vec3 pos) {
  vec3 p = pos;
  float acc = 0.0;
  float weight = 0.55;
  float foldScale = clamp(uPower, 1.35, 2.85);
  int maxIter = int(clamp(uIterations, 3.0, 32.0));
  for (int i = 0; i < 32; i++) {
    if (i >= maxIter) break;
    p = sortAbs(p);
    acc += weight * length(fract(p * 0.7) - 0.5);
    p = p * foldScale - vec3(foldScale - 1.0);
    float k = clamp(1.15 / max(dot(p, p), 0.0005), 0.55, 2.6);
    p *= k;
    weight *= 0.58;
  }
  return acc;
}

vec3 normalAt(vec3 p) {
  float e = 0.0015;
  float d = apollonianDE(p);
  return normalize(vec3(
    apollonianDE(p + vec3(e, 0.0, 0.0)) - d,
    apollonianDE(p + vec3(0.0, e, 0.0)) - d,
    apollonianDE(p + vec3(0.0, 0.0, e)) - d
  ));
}

vec4 march(vec3 ro, vec3 rd) {
  float t = 0.0;
  int maxSteps = int(clamp(uSteps, 20.0, 200.0));
  for (int i = 0; i < 200; i++) {
    if (i >= maxSteps) break;
    vec3 p = ro + rd * t;
    float d = apollonianDE(p);
    if (d < 0.0012) return vec4(p, float(i));
    t += d * 0.82;
    if (t > 18.0) break;
  }
  return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / max(uResolution.y, 1.0);

  mat3 rot = rotationMatrix(uRotation);
  vec3 ro = rot * vec3(0.0, 0.0, 3.8 / max(uZoom, 0.1));
  vec3 forward = normalize(-ro);
  vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
  vec3 up = cross(forward, right);
  vec3 rd = normalize(forward + uv.x * right + uv.y * up);

  vec4 hit = march(ro, rd);
  vec3 color;
  float alpha = 1.0;

  if (hit.w >= 0.0) {
    vec3 n = normalAt(hit.xyz);
    vec3 view = normalize(ro - hit.xyz);
    vec3 light1 = normalize(vec3(3.5, 4.0, 2.8) - hit.xyz);
    vec3 light2 = normalize(vec3(-3.0, -1.5, -2.0) - hit.xyz);
    float diff = max(dot(n, light1), 0.0) + 0.28 * max(dot(n, light2), 0.0);
    float spec = pow(max(dot(n, normalize(light1 + view)), 0.0), 64.0);
    float t = fract(apollonianColor(hit.xyz) + hit.w / max(uSteps, 1.0));
    vec3 base = palette(t, uColorScheme);
    color = base * (0.10 + 0.78 * diff) + vec3(1.0, 0.92, 0.78) * spec * 0.45;
    color = mix(vec3(0.015, 0.015, 0.028), color, exp(-0.08 * length(hit.xyz - ro)));
  } else {
    color = mix(vec3(0.01, 0.01, 0.02), vec3(0.04, 0.045, 0.08), uv.y * 0.5 + 0.5);
    alpha = uTransparentBg > 0.5 ? 0.0 : 1.0;
  }

  fragColor = vec4(linearToSRGB(color), alpha);
}
