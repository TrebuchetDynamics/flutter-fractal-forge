#include <flutter/runtime_effect.glsl>

precision highp float;

// Pseudo-Kleinian community distance estimator. This is intentionally named
// "pseudo": it is a box-fold/sphere-inversion system, not a Kleinian group.
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

vec3 linearToSRGB(vec3 value) {
    value = clamp(value, 0.0, 1.0);
    bvec3 cutoff = lessThan(value, vec3(0.0031308));
    vec3 high = 1.055 * pow(max(value, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
    vec3 low = value * 12.92;
    return mix(high, low, vec3(cutoff));
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

float pseudoKleinianDistance(vec3 point) {
    vec3 z = point;
    float derivative = 1.0;
    float foldScale = clamp(uPower, 1.5, 2.3);
    int maxIterations = int(clamp(uIterations, 1.0, 16.0));

    for (int iteration = 0; iteration < 16; iteration++) {
        if (iteration >= maxIterations) break;
        z = 2.0 * clamp(z, vec3(-1.0, -1.0, -1.3), vec3(1.0, 1.0, 1.3)) - z;
        float radiusSquared = max(dot(z, z), 1.0e-6);
        float inversion = max(1.0 / radiusSquared, 1.0);
        z *= inversion;
        derivative *= inversion;
        z = z * foldScale + vec3(-0.08, 0.05, 0.03);
        derivative = derivative * abs(foldScale) + 1.0;
    }

    float shell = abs(length(z) - 0.92784);
    float crossSection = min(
        max(abs(z.x), abs(z.y)),
        min(max(abs(z.x), abs(z.z)), max(abs(z.y), abs(z.z)))
    );
    return max(shell, crossSection * 0.24 - 0.035) / max(derivative, 1.0e-6);
}

vec3 surfaceNormal(vec3 point) {
    const float epsilon = 0.0012;
    vec2 e = vec2(1.0, -1.0) * epsilon;
    return normalize(
        e.xyy * pseudoKleinianDistance(point + e.xyy) +
        e.yyx * pseudoKleinianDistance(point + e.yyx) +
        e.yxy * pseudoKleinianDistance(point + e.yxy) +
        e.xxx * pseudoKleinianDistance(point + e.xxx)
    );
}

vec3 palette(float phase) {
    float shifted = phase + uColorScheme * 0.17 + uFractalType * 0.000001;
    return 0.5 + 0.5 * cos(6.28318 * (shifted + vec3(0.0, 0.33, 0.67)));
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;
    mat3 rotation = rotationMatrix(uRotation);
    vec3 target = vec3(uMousePos, 0.0);
    vec3 origin = target + rotation * vec3(0.0, 0.0, 3.2 / max(uZoom, 0.2));
    vec3 direction = normalize(rotation * vec3(uv, -1.5));
    int maxSteps = int(clamp(uSteps, 20.0, 160.0));
    float hitThreshold = 0.001 / max(uZoom, 0.2);
    float travelled = 0.0;
    float hitStep = -1.0;
    vec3 hitPoint = origin;

    for (int stepIndex = 0; stepIndex < 160; stepIndex++) {
        if (stepIndex >= maxSteps) break;
        hitPoint = origin + direction * travelled;
        float distanceValue = pseudoKleinianDistance(hitPoint);
        if (distanceValue < hitThreshold) {
            hitStep = float(stepIndex);
            break;
        }
        travelled += max(distanceValue * 0.7, hitThreshold * 0.35);
        if (travelled > max(uBailout, 4.0)) break;
    }

    if (hitStep < 0.0) {
        if (uTransparentBg > 0.5) {
            fragColor = vec4(0.0);
            return;
        }
        vec3 background = mix(vec3(0.012, 0.018, 0.03), vec3(0.055, 0.04, 0.085), uv.y * 0.5 + 0.5);
        fragColor = vec4(linearToSRGB(background), 1.0);
        return;
    }

    vec3 normal = surfaceNormal(hitPoint);
    vec3 lightDirection = normalize(vec3(0.8, 0.9, 0.5));
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float rim = pow(1.0 - max(dot(normal, -direction), 0.0), 2.0);
    float phase = hitStep / max(uSteps, 1.0) + 0.12 * length(hitPoint) + uTime * 0.00003;
    vec3 color = palette(phase) * (0.18 + 0.82 * diffuse) + rim * 0.22;
    fragColor = vec4(linearToSRGB(color), 1.0);
}
