#include <flutter/runtime_effect.glsl>

precision highp float;

// Mandelbox with generalized shape inversions.
// Replaces the standard sphere inversion with a shape-dependent inversion:
//   0 = sphere (classic Mandelbox), 1 = cube, 2 = torus, 3 = octahedron.
// The shape inversion computes a pseudo-radius r2 from the chosen geometry
// and applies the same fold logic: if r2 < minR2, scale up; if r2 < fixedR2,
// scale to fixedR2.  This produces four distinct families of fractal surface.
// uPower controls the scale factor (default 2.0); uFractalType selects shape.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uMousePos;      // 3-4, pan target
uniform float uZoom;          // 5
uniform vec3  uRotation;      // 6-8
uniform float uPower;         // 9
uniform float uIterations;    // 10
uniform float uSteps;         // 11
uniform float uBailout;       // 12
uniform float uColorScheme;   // 13
uniform float uFractalType;   // 14
uniform float uTransparentBg; // 15

out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
    lin = clamp(lin, 0.0, 1.0);
    bvec3 cutoff = lessThan(lin, vec3(0.0031308));
    vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
    vec3 lo = lin * 12.92;
    return mix(hi, lo, vec3(cutoff));
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

vec3 palette(float t, float scheme) {
    int s = int(mod(scheme, 8.0));
    vec3 a, b, c, d;
    if (s == 0) {
        a = vec3(0.5, 0.1, 0.0); b = vec3(0.5, 0.3, 0.1);
        c = vec3(1.0, 0.7, 0.4); d = vec3(0.00, 0.15, 0.20);
    } else if (s == 1) {
        a = vec3(0.0, 0.2, 0.4); b = vec3(0.1, 0.3, 0.4);
        c = vec3(0.8, 0.8, 0.5); d = vec3(0.00, 0.10, 0.20);
    } else if (s == 2) {
        a = vec3(0.1, 0.1, 0.5); b = vec3(0.4, 0.2, 0.5);
        c = vec3(1.0, 1.0, 0.5); d = vec3(0.00, 0.33, 0.67);
    } else if (s == 3) {
        a = vec3(0.5, 0.4, 0.1); b = vec3(0.5, 0.3, 0.1);
        c = vec3(1.0, 0.8, 0.4); d = vec3(0.00, 0.10, 0.20);
    } else if (s == 4) {
        a = vec3(0.5, 0.7, 0.9); b = vec3(0.3, 0.3, 0.3);
        c = vec3(0.5, 0.5, 0.5); d = vec3(0.00, 0.10, 0.20);
    } else if (s == 5) {
        a = vec3(0.4, 0.0, 0.5); b = vec3(0.4, 0.2, 0.3);
        c = vec3(0.8, 0.6, 1.0); d = vec3(0.00, 0.20, 0.50);
    } else if (s == 6) {
        a = vec3(0.5); b = vec3(0.5);
        c = vec3(1.0); d = vec3(0.00, 0.00, 0.00);
    } else {
        a = vec3(0.5); b = vec3(0.5);
        c = vec3(1.0); d = vec3(0.00, 0.33, 0.67);
    }
    return a + b * cos(6.28318 * (c * t + d));
}

// Compute shape-dependent pseudo-radius squared.
float shapeR2(vec3 z, int shape) {
    if (shape == 0) {
        // Sphere: standard Euclidean distance squared.
        return dot(z, z);
    } else if (shape == 1) {
        // Cube: L-infinity norm squared.
        float m = max(abs(z.x), max(abs(z.y), abs(z.z)));
        return m * m;
    } else if (shape == 2) {
        // Torus: distance from a ring of radius 0.5 in xy-plane.
        float q = length(z.xy) - 0.5;
        return q * q + z.z * z.z;
    } else {
        // Octahedron: L1 norm squared (scaled).
        float l1 = abs(z.x) + abs(z.y) + abs(z.z);
        return l1 * l1 * 0.33;
    }
}

// Shape-inversion Mandelbox distance estimator.
float shapeMandelboxDE(vec3 pos) {
    int maxIter = int(clamp(uIterations, 1.0, 20.0));
    int shape = int(mod(uFractalType, 4.0));
    float scale = uPower;
    vec3 z = pos;
    float dr = 1.0;

    for (int i = 0; i < 20; i++) {
        if (i >= maxIter) break;

        // Box fold: reflect about +/-1 on each axis.
        z = clamp(z, -1.0, 1.0) * 2.0 - z;

        // Shape inversion (replaces sphere fold).
        float r2 = shapeR2(z, shape);
        float factor = clamp(1.0 / max(r2, 0.25), 1.0, 4.0);
        z *= factor;
        dr *= factor;

        // Scale and translate.
        z = z * scale + pos;
        dr = dr * abs(scale) + 1.0;
    }

    return length(z) / abs(dr);
}

vec3 getNormal(vec3 pos) {
    float eps = 0.001;
    float d = shapeMandelboxDE(pos);
    return normalize(vec3(
        shapeMandelboxDE(pos + vec3(eps, 0.0, 0.0)) - d,
        shapeMandelboxDE(pos + vec3(0.0, eps, 0.0)) - d,
        shapeMandelboxDE(pos + vec3(0.0, 0.0, eps)) - d
    ));
}

vec3 calculateLighting(vec3 position, vec3 normal, vec3 baseColor, vec3 cameraPos) {
    vec3 viewDir = normalize(cameraPos - position);
    vec3 l1 = normalize(vec3(3.0, 5.0, 4.0) - position);
    float d1 = max(dot(normal, l1), 0.0);
    float s1 = pow(max(dot(normal, normalize(l1 + viewDir)), 0.0), 48.0);
    vec3 l2 = normalize(vec3(-4.0, 2.0, -1.0) - position);
    float d2 = max(dot(normal, l2), 0.0) * 0.35;
    vec3 l3 = normalize(vec3(0.0, -3.0, -5.0) - position);
    float d3 = max(dot(normal, l3), 0.0) * 0.2;
    vec3 col = baseColor * (0.08 + d1 * 0.7 + d2 + d3);
    col += vec3(0.9, 0.95, 1.0) * s1 * 0.4;
    return col;
}

vec4 rayMarch(vec3 origin, vec3 direction) {
    float totalDist = 0.0;
    int maxSteps = int(clamp(uSteps, 10.0, 150.0));
    float minDist = 0.001 / max(uZoom, 0.1);

    for (int i = 0; i < 150; i++) {
        if (i >= maxSteps) break;
        vec3 pos = origin + totalDist * direction;
        float dist = shapeMandelboxDE(pos);
        if (dist < minDist) {
            return vec4(pos, float(i));
        }
        totalDist += dist * 0.9;
        if (totalDist > 20.0) break;
    }
    return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    mat3 rot = rotationMatrix(uRotation);
    vec3 target = vec3(uMousePos, 0.0);
    vec3 camPos = target + rot * vec3(0.0, 0.0, 3.0 / max(uZoom, 0.1));
    vec3 rayDir = normalize(rot * vec3(uv.x, uv.y, -1.5));

    vec4 hit = rayMarch(camPos, rayDir);

    vec3 color;
    float alpha;

    if (hit.w >= 0.0) {
        vec3 normal = getNormal(hit.xyz);
        float t = hit.w / max(uSteps, 1.0);
        vec3 baseColor = palette(t, uColorScheme);
        color = calculateLighting(hit.xyz, normal, baseColor, camPos);
        float dist = length(hit.xyz - camPos);
        float fog = exp(-dist * 0.12);
        color = mix(vec3(0.02, 0.02, 0.04), color, fog);
        alpha = 1.0;
    } else {
        vec3 bgTop = vec3(0.05, 0.05, 0.12);
        vec3 bgBot = vec3(0.02, 0.02, 0.04);
        color = mix(bgBot, bgTop, uv.y * 0.5 + 0.5);
        alpha = mix(1.0, 0.0, step(0.5, uTransparentBg));
    }

    fragColor = vec4(linearToSRGB(color), alpha);
}
