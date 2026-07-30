#include <flutter/runtime_effect.glsl>

precision highp float;

// Implicit affine fractal surface rendered with the standard 3D ray-march
// uniform layout. Repeated absolute folds, axis sorting, scaling, and
// translation define the self-similar distance field.
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

float distanceEstimator(vec3 point, int maxIterations) {
    float scale = clamp(uPower, 1.2, 2.2);
    float totalScale = 1.0;
    for (int i = 0; i < 20; i++) {
        if (i >= maxIterations) break;
        point = abs(point);
        if (point.x < point.y) point.xy = point.yx;
        if (point.x < point.z) point.xz = point.zx;
        point = point * scale - vec3(0.55, 0.35, 0.25);
        totalScale *= scale;
    }
    return length(point) / totalScale;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;
    mat3 rotation = rotationMatrix(uRotation);
    vec3 target = vec3(uMousePos, 0.0);
    vec3 origin = target + rotation * vec3(0.0, 0.0, 3.0 / max(uZoom, 0.2));
    vec3 direction = normalize(rotation * vec3(uv, -1.4));
    int maxIterations = int(clamp(uIterations, 1.0, 20.0));
    int maxSteps = int(clamp(uSteps, 20.0, 200.0));
    float epsilon = 0.001 / max(uZoom, 0.2);
    float maxDistance = max(uBailout, 2.0);
    float distanceTravelled = 0.0;
    float hitStep = -1.0;

    for (int i = 0; i < 200; i++) {
        if (i >= maxSteps) break;
        float distance = distanceEstimator(origin + direction * distanceTravelled, maxIterations);
        if (distance < epsilon) {
            hitStep = float(i);
            break;
        }
        distanceTravelled += distance * 0.8;
        if (distanceTravelled > maxDistance) break;
    }

    if (hitStep < 0.0) {
        if (uTransparentBg > 0.5) {
            fragColor = vec4(0.0);
            return;
        }
        fragColor = vec4(linearToSRGB(vec3(0.02, 0.025, 0.04)), 1.0);
        return;
    }

    float phase = hitStep / max(uSteps, 1.0) + uColorScheme * 0.17;
    vec3 color = 0.5 + 0.5 * cos(6.28318 * (phase + vec3(0.0, 0.33, 0.67)));
    fragColor = vec4(linearToSRGB(color), 1.0);
}
