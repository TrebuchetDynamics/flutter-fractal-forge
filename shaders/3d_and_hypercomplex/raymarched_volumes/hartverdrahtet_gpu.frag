#include <flutter/runtime_effect.glsl>

precision highp float;

// Hartverdrahtet — documented 3D ray-marched fractal expansion.
// Uses the shared Raymarched3DConfig uniform layout.

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
    int s = int(mod(scheme, 4.0));
    if (s == 1) return 0.45 + 0.45 * cos(6.28318 * (vec3(0.05, 0.35, 0.60) + t));
    if (s == 2) return 0.45 + 0.45 * cos(6.28318 * (vec3(0.80, 0.45, 0.15) + t));
    if (s == 3) return mix(vec3(0.06, 0.08, 0.12), vec3(0.95, 0.92, 0.82), t);
    return 0.45 + 0.45 * cos(6.28318 * (vec3(0.00, 0.18, 0.38) + t));
}

float boxDE(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sphereDE(vec3 p, float r) {
    return length(p) - r;
}


float fractalDE(vec3 p) {
    vec3 z = p;
    float scale = clamp(uPower, 1.4, 3.6);
    float dr = 1.0;
    int maxIter = int(clamp(uIterations, 5.0, 32.0));
    for (int i = 0; i < 32; i++) {
        if (i >= maxIter) break;
        z = abs(z);
        if (z.x < z.y) z.xy = z.yx;
        if (z.x < z.z) z.xz = z.zx;
        z = z * scale - vec3(1.0, 0.82, 0.68) * (scale - 1.0);
        z.xy = mat2(0.866, -0.5, 0.5, 0.866) * z.xy;
        float r2 = dot(z, z);
        float fold = clamp(1.4 / max(r2, 0.18), 0.65, 2.8);
        z *= fold;
        dr = dr * abs(scale * fold) + 1.0;
    }
    float wire = min(length(z.xy) - 0.18, min(length(z.yz) - 0.16, length(z.xz) - 0.14));
    return min(length(z) / max(dr, 0.0001), abs(wire) / max(dr, 0.0001));
}


float sceneDE(vec3 p) {
    return max(fractalDE(p), 0.0001);
}

vec3 getNormal(vec3 p) {
    float e = 0.0015;
    vec2 h = vec2(e, 0.0);
    return normalize(vec3(
        sceneDE(p + h.xyy) - sceneDE(p - h.xyy),
        sceneDE(p + h.yxy) - sceneDE(p - h.yxy),
        sceneDE(p + h.yyx) - sceneDE(p - h.yyx)
    ));
}

float ambientOcclusion(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 1; i <= 5; i++) {
        float h = 0.025 * float(i);
        float d = sceneDE(p + n * h);
        occ += (h - d) * sca;
        sca *= 0.6;
    }
    return clamp(1.0 - occ * 2.0, 0.0, 1.0);
}

vec4 rayMarch(vec3 ro, vec3 rd) {
    float t = 0.0;
    int maxSteps = int(clamp(uSteps, 30.0, 170.0));
    float eps = 0.0012 / max(uZoom, 0.1);
    for (int i = 0; i < 170; i++) {
        if (i >= maxSteps) break;
        vec3 p = ro + rd * t;
        float d = sceneDE(p);
        if (d < eps) return vec4(p, float(i));
        t += d * 0.82;
        if (t > 22.0) break;
    }
    return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    mat3 rot = rotationMatrix(uRotation);
    vec3 ro = rot * vec3(0.0, 0.0, 3.2 / max(uZoom, 0.1));
    vec3 fw = normalize(-ro);
    vec3 rt = normalize(cross(vec3(0.0, 1.0, 0.0), fw));
    vec3 up = cross(fw, rt);
    vec3 rd = normalize(fw + uv.x * rt + uv.y * up);

    vec4 hit = rayMarch(ro, rd);
    vec3 color;
    float alpha;
    if (hit.w >= 0.0) {
        vec3 n = getNormal(hit.xyz);
        vec3 lightA = normalize(vec3(4.0, 5.0, 3.0));
        vec3 lightB = normalize(vec3(-3.0, 2.0, -4.0));
        float diff = max(dot(n, lightA), 0.0) * 0.75 + max(dot(n, lightB), 0.0) * 0.25;
        vec3 view = normalize(ro - hit.xyz);
        float spec = pow(max(dot(reflect(-lightA, n), view), 0.0), 36.0) * 0.35;
        float ao = ambientOcclusion(hit.xyz, n);
        float bands = 0.5 + 0.5 * sin(length(hit.xyz) * 7.0 + hit.w * 0.08);
        vec3 baseColor = palette(fract(hit.w / max(uSteps, 1.0) + bands * 0.15), uColorScheme);
        color = baseColor * (0.10 + diff) * ao + vec3(spec);
        float fog = exp(-length(hit.xyz - ro) * 0.12);
        color = mix(vec3(0.018, 0.020, 0.035), color, fog);
        alpha = 1.0;
    } else {
        color = mix(vec3(0.015, 0.017, 0.030), vec3(0.045, 0.050, 0.085), uv.y * 0.5 + 0.5);
        alpha = mix(1.0, 0.0, step(0.5, uTransparentBg));
    }
    fragColor = vec4(linearToSRGB(color), alpha);
}
