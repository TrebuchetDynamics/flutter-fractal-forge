#include <flutter/runtime_effect.glsl>

precision highp float;

// Shared renderer for four distinct deterministic 3D transform systems:
// 0 = center-cross Vicsek IFS (7 maps, ratio 1/3)
// 1 = Jerusalem cube (8 corner maps at sqrt(2)-1 and 12 edge maps at r^2)
// 2 = Sierpinski octahedron (6 maps, ratio 1/2)
// 3 = Cartesian Cantor dust C^3 (8 corner maps, ratio 1/3)
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

float boxDistance(vec3 point) {
    vec3 q = abs(point) - vec3(1.0);
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float octahedronDistance(vec3 point) {
    return (abs(point.x) + abs(point.y) + abs(point.z) - 1.0) * 0.57735026919;
}

float vicsekDistance(vec3 point, int depth) {
    float worldScale = 1.0;
    const float childScale = 0.33333333333;
    const float childOffset = 0.66666666667;
    for (int iteration = 0; iteration < 12; iteration++) {
        if (iteration >= depth) break;
        float best = 1.0e9;
        vec3 bestPoint = point / childScale;
        for (int child = 0; child < 7; child++) {
            vec3 center = vec3(0.0);
            if (child > 0) {
                int axis = (child - 1) / 2;
                float signValue = ((child - 1) - axis * 2 == 0) ? -1.0 : 1.0;
                if (axis == 0) center.x = signValue * childOffset;
                if (axis == 1) center.y = signValue * childOffset;
                if (axis == 2) center.z = signValue * childOffset;
            }
            vec3 candidate = (point - center) / childScale;
            float distanceValue = boxDistance(candidate) * childScale;
            if (distanceValue < best) {
                best = distanceValue;
                bestPoint = candidate;
            }
        }
        point = bestPoint;
        worldScale *= childScale;
    }
    return abs(boxDistance(point)) * worldScale;
}

float jerusalemDistance(vec3 point, int depth) {
    const float cornerScale = 0.41421356237; // sqrt(2)-1
    const float edgeScale = 0.17157287525;   // cornerScale^2
    const float cornerOffset = 0.58578643763;
    const float edgeOffset = 0.82842712475;
    float worldScale = 1.0;

    for (int iteration = 0; iteration < 9; iteration++) {
        if (iteration >= depth) break;
        float best = 1.0e9;
        float selectedScale = cornerScale;
        vec3 bestPoint = point;

        for (int child = 0; child < 8; child++) {
            int xBit = child - (child / 2) * 2;
            int yBit = (child / 2) - (child / 4) * 2;
            int zBit = child / 4;
            vec3 center = cornerOffset * vec3(
                xBit == 0 ? -1.0 : 1.0,
                yBit == 0 ? -1.0 : 1.0,
                zBit == 0 ? -1.0 : 1.0
            );
            vec3 candidate = (point - center) / cornerScale;
            float distanceValue = boxDistance(candidate) * cornerScale;
            if (distanceValue < best) {
                best = distanceValue;
                selectedScale = cornerScale;
                bestPoint = candidate;
            }
        }

        for (int child = 0; child < 12; child++) {
            int axis = child / 4;
            int signs = child - axis * 4;
            float firstSign = (signs - (signs / 2) * 2 == 0) ? -1.0 : 1.0;
            float secondSign = (signs / 2 == 0) ? -1.0 : 1.0;
            vec3 center;
            if (axis == 0) center = vec3(0.0, firstSign * edgeOffset, secondSign * edgeOffset);
            else if (axis == 1) center = vec3(firstSign * edgeOffset, 0.0, secondSign * edgeOffset);
            else center = vec3(firstSign * edgeOffset, secondSign * edgeOffset, 0.0);
            vec3 candidate = (point - center) / edgeScale;
            float distanceValue = boxDistance(candidate) * edgeScale;
            if (distanceValue < best) {
                best = distanceValue;
                selectedScale = edgeScale;
                bestPoint = candidate;
            }
        }

        point = bestPoint;
        worldScale *= selectedScale;
    }
    return abs(boxDistance(point)) * worldScale;
}

float octahedronFractalDistance(vec3 point, int depth) {
    float worldScale = 1.0;
    const float childScale = 0.5;
    const float childOffset = 0.5;
    for (int iteration = 0; iteration < 12; iteration++) {
        if (iteration >= depth) break;
        float best = 1.0e9;
        vec3 bestPoint = point;
        for (int child = 0; child < 6; child++) {
            int axis = child / 2;
            float signValue = (child - axis * 2 == 0) ? -1.0 : 1.0;
            vec3 center = vec3(0.0);
            if (axis == 0) center.x = signValue * childOffset;
            if (axis == 1) center.y = signValue * childOffset;
            if (axis == 2) center.z = signValue * childOffset;
            vec3 candidate = (point - center) / childScale;
            float distanceValue = abs(octahedronDistance(candidate)) * childScale;
            if (distanceValue < best) {
                best = distanceValue;
                bestPoint = candidate;
            }
        }
        point = bestPoint;
        worldScale *= childScale;
    }
    return abs(octahedronDistance(point)) * worldScale;
}

float cantorDustDistance(vec3 point, int depth) {
    float worldScale = 1.0;
    const float cantorScale = 0.33333333333;
    const float cantorOffset = 0.66666666667;
    for (int iteration = 0; iteration < 10; iteration++) {
        if (iteration >= depth) break;
        float best = 1.0e9;
        vec3 bestPoint = point;
        for (int child = 0; child < 8; child++) {
            int xBit = child - (child / 2) * 2;
            int yBit = (child / 2) - (child / 4) * 2;
            int zBit = child / 4;
            vec3 center = cantorOffset * vec3(
                xBit == 0 ? -1.0 : 1.0,
                yBit == 0 ? -1.0 : 1.0,
                zBit == 0 ? -1.0 : 1.0
            );
            vec3 candidate = (point - center) / cantorScale;
            float distanceValue = boxDistance(candidate) * cantorScale;
            if (distanceValue < best) {
                best = distanceValue;
                bestPoint = candidate;
            }
        }
        point = bestPoint;
        worldScale *= cantorScale;
    }
    return abs(boxDistance(point)) * worldScale;
}

float sceneDistance(vec3 point) {
    int depth = int(clamp(uIterations, 1.0, 12.0));
    int fractalType = int(uFractalType);
    if (fractalType == 1) {
        int jerusalemDepth = depth;
        if (jerusalemDepth > 9) jerusalemDepth = 9;
        return jerusalemDistance(point, jerusalemDepth);
    }
    if (fractalType == 2) return octahedronFractalDistance(point, depth);
    if (fractalType == 3) {
        int cantorDepth = depth;
        if (cantorDepth > 10) cantorDepth = 10;
        return cantorDustDistance(point, cantorDepth);
    }
    return vicsekDistance(point, depth);
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
    float shifted = phase + uColorScheme * 0.17 + uPower * 0.000001;
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
        travelled += max(distanceValue * 0.65, hitThreshold * 0.35);
        if (travelled > max(uBailout, 3.0)) break;
    }

    if (hitStep < 0.0) {
        if (uTransparentBg > 0.5) {
            fragColor = vec4(0.0);
            return;
        }
        vec3 background = mix(vec3(0.015, 0.02, 0.035), vec3(0.045, 0.055, 0.09), uv.y * 0.5 + 0.5);
        fragColor = vec4(linearToSRGB(background), 1.0);
        return;
    }

    vec3 normal = surfaceNormal(hitPoint);
    vec3 lightDirection = normalize(vec3(0.7, 0.9, 0.6));
    float diffuse = max(dot(normal, lightDirection), 0.0);
    float rim = pow(1.0 - max(dot(normal, -direction), 0.0), 2.0);
    float phase = hitStep / max(uSteps, 1.0) + 0.08 * length(hitPoint) + uTime * 0.00003;
    vec3 color = palette(phase) * (0.22 + 0.78 * diffuse) + rim * 0.18;
    fragColor = vec4(linearToSRGB(color), 1.0);
}
