#include <flutter/runtime_effect.glsl>

precision highp float;

// Three-dimensional slice of the quadratic quaternion Mandelbrot set.
// Each sampled position is the quaternion parameter c=(x,y,z,0), with q0=0,
// and the orbit follows q(n+1)=q(n)^2+c. This is parameter space, not a Julia
// set with a fixed c.
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

float quaternionMandelbrotDistance(vec3 pos) {
    vec4 z = vec4(0.0);
    vec4 c = vec4(pos, 0.0);
    float derivative = 0.0;
    float bailoutSquared = max(uBailout, 2.0) * max(uBailout, 2.0);
    int maxIterations = int(clamp(uIterations, 1.0, 24.0));
    bool escaped = false;

    for (int iteration = 0; iteration < 24; iteration++) {
        if (iteration >= maxIterations) break;
        derivative = 2.0 * length(z) * derivative + 1.0;
        vec4 zSquared;
        zSquared.x = z.x * z.x - dot(z.yzw, z.yzw);
        zSquared.yzw = 2.0 * z.x * z.yzw;
        z = zSquared + c;
        if (dot(z, z) > bailoutSquared) {
            escaped = true;
            break;
        }
    }

    if (!escaped) return 0.0;
    float radius = max(length(z), 1.0e-8);
    return max(0.0, 0.5 * radius * log(radius) / max(derivative, 1.0e-8));
}

float sceneDistance(vec3 point) {
    return quaternionMandelbrotDistance(point);
}

vec3 surfaceNormal(vec3 point) {
    const float epsilon = 0.0015;
    vec2 e = vec2(1.0, -1.0) * epsilon;
    return normalize(
        e.xyy * sceneDistance(point + e.xyy) +
        e.yyx * sceneDistance(point + e.yyx) +
        e.yxy * sceneDistance(point + e.yxy) +
        e.xxx * sceneDistance(point + e.xxx)
    );
}

vec3 palette(float phase) {
    float shifted = phase + uColorScheme * 0.17 + uPower * 0.000001 +
        uFractalType * 0.000001 + uTime * 0.000003;
    return 0.5 + 0.5 * cos(6.28318 * (shifted + vec3(0.0, 0.33, 0.67)));
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;
    mat3 rotation = rotationMatrix(uRotation);
    vec3 target = vec3(uMousePos, 0.0);
    vec3 origin = target + rotation * vec3(0.0, 0.0, 3.4 / max(uZoom, 0.2));
    vec3 direction = normalize(rotation * vec3(uv, -1.5));
    int maxSteps = int(clamp(uSteps, 20.0, 160.0));
    float hitThreshold = 0.0012 / max(uZoom, 0.2);
    float travelled = 0.0;
    float hitStep = -1.0;
    vec3 hitPoint = origin;

    for (int stepIndex = 0; stepIndex < 160; stepIndex++) {
        if (stepIndex >= maxSteps) break;
        hitPoint = origin + direction * travelled;
        float distanceValue = sceneDistance(hitPoint);
        if (distanceValue < hitThreshold) {
            hitStep = float(stepIndex);
            break;
        }
        travelled += max(distanceValue * 0.8, hitThreshold * 0.35);
        if (travelled > max(uBailout, 6.0)) break;
    }

    if (hitStep < 0.0) {
        if (uTransparentBg > 0.5) {
            fragColor = vec4(0.0);
            return;
        }
        vec3 background = mix(
            vec3(0.012, 0.018, 0.035),
            vec3(0.05, 0.055, 0.10),
            uv.y * 0.5 + 0.5
        );
        fragColor = vec4(linearToSRGB(background), 1.0);
        return;
    }

    vec3 normal = surfaceNormal(hitPoint);
    vec3 lightDirection = normalize(vec3(0.7, 0.9, 0.6));
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float rim = pow(1.0 - max(dot(normal, -direction), 0.0), 2.0);
    float phase = hitStep / max(uSteps, 1.0) + 0.08 * length(hitPoint);
    vec3 color = palette(phase) * (0.2 + 0.8 * diffuse) + rim * 0.2;
    fragColor = vec4(linearToSRGB(color), 1.0);
}
