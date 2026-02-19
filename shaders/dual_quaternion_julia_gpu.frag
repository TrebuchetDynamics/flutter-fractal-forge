#include <flutter/runtime_effect.glsl>

precision highp float;

// Dual-Quaternion Julia fractal — extends quaternion Julia with a dual
// coupling term that creates asymmetric distortion in the 4th component.
// The dual part introduces cross-talk between y and z into w, breaking
// the rotational symmetry of standard quaternion Julia and producing
// twisted, organic-looking surfaces.
// uPower controls dual coupling strength; uFractalType selects c preset.

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

// Select c constant for dual-quaternion Julia.
vec4 getDualJuliaC() {
    int preset = int(uFractalType) % 4;
    if (preset == 0) return vec4(-0.2, 0.4, 0.2, -0.3);
    if (preset == 1) return vec4(0.3, -0.3, 0.4, 0.1);
    if (preset == 2) return vec4(-0.4, 0.1, -0.2, 0.5);
    return vec4(0.1, 0.5, -0.3, -0.2);
}

// Dual-quaternion Julia distance estimator.
// Standard quaternion squaring with a dual coupling term in w:
//   w_new += dual * y * z, breaking quaternion symmetry.
float dualQuatJuliaDE(vec3 pos) {
    int maxIter = int(clamp(uIterations, 1.0, 20.0));
    vec4 z = vec4(pos, 0.0);
    vec4 c = getDualJuliaC();
    float dual = 0.1 * uPower;
    float dz = 1.0;
    float bailSq = uBailout * uBailout;

    for (int i = 0; i < 20; i++) {
        if (i >= maxIter) break;
        dz = 2.0 * length(z) * dz + 1.0;
        // Modified quaternion square with dual coupling in w component.
        float w2 = z.x * z.x - z.y * z.y - z.z * z.z - z.w * z.w;
        float xy = 2.0 * z.x * z.y;
        float xz = 2.0 * z.x * z.z;
        float xw = 2.0 * z.x * z.w + dual * z.y * z.z;
        z = vec4(w2, xy, xz, xw) + c;
        if (dot(z, z) > bailSq) break;
    }

    float r = length(z);
    return 0.5 * r * log(r) / max(dz, 1e-12);
}

vec3 getNormal(vec3 pos) {
    float eps = 0.001;
    float d = dualQuatJuliaDE(pos);
    return normalize(vec3(
        dualQuatJuliaDE(pos + vec3(eps, 0.0, 0.0)) - d,
        dualQuatJuliaDE(pos + vec3(0.0, eps, 0.0)) - d,
        dualQuatJuliaDE(pos + vec3(0.0, 0.0, eps)) - d
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
        float dist = dualQuatJuliaDE(pos);
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
