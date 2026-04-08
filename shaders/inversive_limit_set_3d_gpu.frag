#include <flutter/runtime_effect.glsl>

precision highp float;

// Inversive / Kleinian limit set — iterated sphere inversions in 3D.
// Four inversion spheres sit at the vertices of a regular tetrahedron.
// For each iteration, the point is reflected through every sphere it
// lies inside.  The limit set is the attractor of this iterated function
// system, rendered via a distance estimator that tracks the accumulated
// inversion scale.
// uPower controls sphere radii (default 1.4, useful range ~1.0..2.0);
// uFractalType selects arrangement: 0=tetrahedron, 1=cube, 2=octahedron, 3=random.

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uMousePos;      // 3-4
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
    int s = int(scheme) % 8;
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

// Sphere centers for different arrangements.
// Each arrangement places 4 spheres in a symmetric configuration.
void getSpheres(int arrangement, float radius,
                out vec4 s1, out vec4 s2, out vec4 s3, out vec4 s4) {
    if (arrangement == 0) {
        // Tetrahedron vertices.
        s1 = vec4( 1.0,  1.0,  1.0, radius);
        s2 = vec4(-1.0, -1.0,  1.0, radius);
        s3 = vec4( 1.0, -1.0, -1.0, radius);
        s4 = vec4(-1.0,  1.0, -1.0, radius);
    } else if (arrangement == 1) {
        // Cube face centers (4 of 6).
        s1 = vec4( 1.0,  0.0,  0.0, radius);
        s2 = vec4(-1.0,  0.0,  0.0, radius);
        s3 = vec4( 0.0,  1.0,  0.0, radius);
        s4 = vec4( 0.0, -1.0,  0.0, radius);
    } else if (arrangement == 2) {
        // Octahedron-like: along axes plus diagonal.
        s1 = vec4( 0.0,  0.0,  1.2, radius);
        s2 = vec4( 0.0,  0.0, -1.2, radius);
        s3 = vec4( 1.1,  0.6,  0.0, radius);
        s4 = vec4(-1.1, -0.6,  0.0, radius);
    } else {
        // Asymmetric: time-modulated positions for organic motion.
        float t = uTime * 0.0003;
        s1 = vec4( 0.9 + 0.2 * sin(t),        0.9, 0.9, radius);
        s2 = vec4(-0.9, -0.9 + 0.2 * cos(t),  0.9, radius);
        s3 = vec4( 0.9, -0.9, -0.9 + 0.2 * sin(t * 1.3), radius);
        s4 = vec4(-0.9,  0.9, -0.9, radius);
    }
}

// Invert point p through sphere s (center s.xyz, radius s.w).
// Returns true if inversion was applied (point was inside sphere).
bool invertThroughSphere(inout vec3 p, inout float scale, vec4 s) {
    vec3 d = p - s.xyz;
    float r2 = dot(d, d);
    float sr2 = s.w * s.w;
    if (r2 < sr2) {
        float k = sr2 / r2;
        p = s.xyz + d * k;
        scale *= k;
        return true;
    }
    return false;
}

// Inversive limit set distance estimator.
// Iteratively inverts through 4 spheres; the scale accumulation
// gives the derivative for the DE formula.
float inversiveDE(vec3 p) {
    int maxIter = int(clamp(uIterations, 1.0, 30.0));
    float radius = clamp(uPower, 0.5, 3.0);
    int arrangement = int(uFractalType) % 4;

    vec4 s1, s2, s3, s4;
    getSpheres(arrangement, radius, s1, s2, s3, s4);

    float scale = 1.0;
    float lastSphere = 0.0;

    for (int i = 0; i < 30; i++) {
        if (i >= maxIter) break;
        bool inverted = false;
        if (invertThroughSphere(p, scale, s1)) { inverted = true; lastSphere = 0.0; }
        if (invertThroughSphere(p, scale, s2)) { inverted = true; lastSphere = 1.0; }
        if (invertThroughSphere(p, scale, s3)) { inverted = true; lastSphere = 2.0; }
        if (invertThroughSphere(p, scale, s4)) { inverted = true; lastSphere = 3.0; }
        if (!inverted) break;
    }

    // Distance to a small sphere at origin, divided by accumulated scale.
    return (length(p) - 0.1) / max(scale, 1e-8);
}

// Store last-sphere info for coloring: use a separate pass.
float inversiveColor(vec3 p) {
    int maxIter = int(clamp(uIterations, 1.0, 30.0));
    float radius = clamp(uPower, 0.5, 3.0);
    int arrangement = int(uFractalType) % 4;

    vec4 s1, s2, s3, s4;
    getSpheres(arrangement, radius, s1, s2, s3, s4);

    float scale = 1.0;
    float colorAccum = 0.0;
    float weight = 1.0;

    for (int i = 0; i < 30; i++) {
        if (i >= maxIter) break;
        bool inverted = false;
        if (invertThroughSphere(p, scale, s1)) { colorAccum += weight * 0.0;  inverted = true; }
        if (invertThroughSphere(p, scale, s2)) { colorAccum += weight * 0.25; inverted = true; }
        if (invertThroughSphere(p, scale, s3)) { colorAccum += weight * 0.5;  inverted = true; }
        if (invertThroughSphere(p, scale, s4)) { colorAccum += weight * 0.75; inverted = true; }
        weight *= 0.5;
        if (!inverted) break;
    }

    return colorAccum;
}

vec3 getNormal(vec3 pos) {
    float eps = 0.001;
    float d = inversiveDE(pos);
    return normalize(vec3(
        inversiveDE(pos + vec3(eps, 0.0, 0.0)) - d,
        inversiveDE(pos + vec3(0.0, eps, 0.0)) - d,
        inversiveDE(pos + vec3(0.0, 0.0, eps)) - d
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
        float dist = inversiveDE(pos);
        if (dist < minDist) {
            return vec4(pos, float(i));
        }
        totalDist += dist * 0.8;  // slightly more conservative for IFS
        if (totalDist > 20.0) break;
    }
    return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    mat3 rot = rotationMatrix(uRotation);
    vec3 camPos = rot * vec3(0.0, 0.0, 3.0 / max(uZoom, 0.1));
    vec3 forward = normalize(-camPos);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    vec3 rayDir = normalize(forward + uv.x * right + uv.y * up);

    vec4 hit = rayMarch(camPos, rayDir);

    vec3 color;
    float alpha;

    if (hit.w >= 0.0) {
        vec3 normal = getNormal(hit.xyz);
        // Color by which sphere was last inverted through + iteration depth.
        float cVal = inversiveColor(hit.xyz);
        float t = fract(cVal + hit.w / max(uSteps, 1.0));
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
