#include <flutter/runtime_effect.glsl>

precision highp float;

// KIFS Koch Fold — 3D ray-marched distance-estimated fractal.
// Kaleidoscopic IFS using repeated plane reflections that produce a
// Koch-snowflake-like solid in 3D.  Each iteration applies abs-folds
// followed by conditional sign-flips across 45-degree diagonal planes,
// then scales and translates.  uPower controls the scale (default 2.0).

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uMousePos;      // 3-4  (layout compat, unused)
uniform float uZoom;          // 5
uniform vec3  uRotation;      // 6-8
uniform float uPower;         // 9   scale factor (default 2.0)
uniform float uIterations;    // 10
uniform float uSteps;         // 11
uniform float uBailout;       // 12
uniform float uColorScheme;   // 13
uniform float uFractalType;   // 14
uniform float uTransparentBg; // 15

out vec4 fragColor;

// IEC 61966-2-1 sRGB transfer function (linear -> display-encoded).
vec3 linearToSRGB(vec3 lin) {
    lin = clamp(lin, 0.0, 1.0);
    bvec3 cutoff = lessThan(lin, vec3(0.0031308));
    vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
    vec3 lo = lin * 12.92;
    return mix(hi, lo, vec3(cutoff));
}

// Combined rotation matrix from euler angles (XYZ order).
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

// ── Koch 3D distance estimator (KIFS) ──────────────────────────────────
// Reflections across x+y=0, x+z=0, y+z=0 planes create Koch-like
// geometry.  The offset vector keeps the fractal centred as it scales.
float kochDE(vec3 p, int maxIter) {
    float scale = max(uPower, 1.5); // default 2.0
    vec3 offset = vec3(1.0, 0.0, 0.0);

    for (int i = 0; i < 30; i++) {
        if (i >= maxIter) break;

        p = abs(p);

        // Fold across diagonal planes (Koch-style reflections)
        if (p.x + p.y < 0.0) p.xy = -p.yx;
        if (p.x + p.z < 0.0) p.xz = -p.zx;
        if (p.y + p.z < 0.0) p.yz = -p.zy;

        // Scale and translate
        p = p * scale - offset * (scale - 1.0);
    }
    return length(p) * pow(scale, -float(maxIter));
}

// ── Colour palette (4 schemes) ─────────────────────────────────────────
vec3 getColor(float t, int scheme) {
    vec3 fire = mix(vec3(0.1, 0.0, 0.0), vec3(1.0, 0.3, 0.0), t);
    vec3 ocean = mix(vec3(0.0, 0.1, 0.2), vec3(0.0, 0.8, 1.0), t);
    vec3 psychedelic = vec3(
        sin(t * 6.28) * 0.5 + 0.5,
        sin(t * 6.28 + 2.09) * 0.5 + 0.5,
        sin(t * 6.28 + 4.19) * 0.5 + 0.5
    );
    vec3 gray = vec3(t);

    float s0 = step(1.0, float(scheme));
    float s1 = step(2.0, float(scheme));
    float s2 = step(3.0, float(scheme));

    vec3 result = fire;
    result = mix(result, ocean, s0 * (1.0 - s1));
    result = mix(result, psychedelic, s1 * (1.0 - s2));
    result = mix(result, gray, s2);
    return result;
}

// ── Normal via forward differences (4 evaluations) ─────────────────────
vec3 getNormal(vec3 pos, int maxIter) {
    float eps = 0.001;
    float d = kochDE(pos, maxIter);
    return normalize(vec3(
        kochDE(pos + vec3(eps, 0.0, 0.0), maxIter) - d,
        kochDE(pos + vec3(0.0, eps, 0.0), maxIter) - d,
        kochDE(pos + vec3(0.0, 0.0, eps), maxIter) - d
    ));
}

// ── Ambient occlusion (5-step) ─────────────────────────────────────────
float computeAO(vec3 pos, vec3 normal, int maxIter) {
    float ao = 1.0;
    for (int i = 1; i <= 5; i++) {
        float d = float(i) * 0.02;
        ao -= (d - kochDE(pos + normal * d, maxIter)) * pow(2.0, float(i));
    }
    return clamp(ao, 0.0, 1.0);
}

// ── Blinn-Phong lighting ───────────────────────────────────────────────
vec3 calculateLighting(vec3 position, vec3 normal, vec3 color, vec3 cameraPos) {
    vec3 lightDir = normalize(vec3(5.0, 5.0, 5.0) - position);
    vec3 viewDir  = normalize(cameraPos - position);
    vec3 halfDir  = normalize(lightDir + viewDir);

    float diffuse  = max(dot(normal, lightDir), 0.0);
    float specular = pow(max(dot(normal, halfDir), 0.0), 32.0);

    return color * (0.1 + diffuse * 0.8) + vec3(1.0) * specular * 0.3;
}

// ── Ray marching ───────────────────────────────────────────────────────
vec4 rayMarch(vec3 origin, vec3 direction, int maxIter) {
    float totalDistance = 0.0;
    int iterations = 0;

    float lodFactor = clamp(uZoom * 0.5, 0.5, 1.0);
    int maxSteps = int(max(uSteps * lodFactor, 10.0));
    float minDist = 0.001 / max(uZoom, 0.1);

    for (int i = 0; i < 150; i++) {
        if (i >= maxSteps) break;

        iterations = i;
        vec3 pos = origin + totalDistance * direction;
        float distance = kochDE(pos, maxIter);

        if (distance < minDist) {
            return vec4(pos, float(iterations));
        }

        totalDistance += distance * 0.9;

        if (totalDistance > 20.0) break;
    }
    return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    int maxIter = int(uIterations);

    // Camera setup
    mat3 rot     = rotationMatrix(uRotation);
    vec3 camPos  = rot * vec3(0.0, 0.0, 3.0 / max(uZoom, 0.1));
    vec3 forward = normalize(-camPos);
    vec3 right   = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up      = cross(forward, right);
    vec3 rayDir  = normalize(forward + uv.x * right + uv.y * up);

    vec4 hit = rayMarch(camPos, rayDir, maxIter);

    vec3 color;
    float alpha;

    if (hit.w >= 0.0) {
        vec3  normal = getNormal(hit.xyz, maxIter);
        float ao     = computeAO(hit.xyz, normal, maxIter);
        float t      = hit.w / max(uIterations, 1.0);
        vec3  base   = getColor(t, int(uColorScheme));
        color        = calculateLighting(hit.xyz, normal, base, camPos);
        color       *= ao;

        // Distance fog
        float dist = length(hit.xyz - camPos);
        float fog  = exp(-dist * 0.15);
        color      = mix(vec3(0.02), color, fog);
        alpha      = 1.0;
    } else {
        // Background gradient or transparent
        vec3 bgColor = mix(vec3(0.02), vec3(0.05, 0.05, 0.1), uv.y * 0.5 + 0.5);
        alpha = mix(1.0, 0.0, step(0.5, uTransparentBg));
        color = bgColor;
    }

    fragColor = vec4(linearToSRGB(color), alpha);
}
