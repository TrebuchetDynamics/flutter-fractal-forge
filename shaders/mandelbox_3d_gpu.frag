#include <flutter/runtime_effect.glsl>

precision highp float;

// Uniform layout (indices 0-15):
uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec3  uRotation;      // 3-5  euler angles for camera rotation
uniform float uZoom;          // 6
uniform float uIterations;    // 7    max iterations (default 15)
uniform float uColorScheme;   // 8
uniform float uFoldLimit;     // 9    box-fold clamp (default 1.0)
uniform float uFoldValue;     // 10   2*foldLimit (default 2.0)
uniform float uMinR2;         // 11   inner sphere radius² (default 0.25)
uniform float uFixedR2;       // 12   outer sphere radius² (default 1.0)
uniform float uScale;         // 13   scale factor (default 2.0)
uniform float uMaxSteps;      // 14   ray march steps (default 80)
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

// Palette: cosine color palette (IQ-style) driven by colorScheme index.
vec3 palette(float t, float scheme) {
    // Note: SkSL doesn't support % operator
    int schemeInt = int(scheme);
    int s = schemeInt - (schemeInt / 8) * 8;
    vec3 a, b, c, d;
    if (s == 0) {
        // Fire
        a = vec3(0.5, 0.1, 0.0); b = vec3(0.5, 0.3, 0.1);
        c = vec3(1.0, 0.7, 0.4); d = vec3(0.00, 0.15, 0.20);
    } else if (s == 1) {
        // Ocean
        a = vec3(0.0, 0.2, 0.4); b = vec3(0.1, 0.3, 0.4);
        c = vec3(0.8, 0.8, 0.5); d = vec3(0.00, 0.10, 0.20);
    } else if (s == 2) {
        // Electric
        a = vec3(0.1, 0.1, 0.5); b = vec3(0.4, 0.2, 0.5);
        c = vec3(1.0, 1.0, 0.5); d = vec3(0.00, 0.33, 0.67);
    } else if (s == 3) {
        // Gold
        a = vec3(0.5, 0.4, 0.1); b = vec3(0.5, 0.3, 0.1);
        c = vec3(1.0, 0.8, 0.4); d = vec3(0.00, 0.10, 0.20);
    } else if (s == 4) {
        // Ice
        a = vec3(0.5, 0.7, 0.9); b = vec3(0.3, 0.3, 0.3);
        c = vec3(0.5, 0.5, 0.5); d = vec3(0.00, 0.10, 0.20);
    } else if (s == 5) {
        // Violet
        a = vec3(0.4, 0.0, 0.5); b = vec3(0.4, 0.2, 0.3);
        c = vec3(0.8, 0.6, 1.0); d = vec3(0.00, 0.20, 0.50);
    } else if (s == 6) {
        // Grayscale
        a = vec3(0.5); b = vec3(0.5);
        c = vec3(1.0); d = vec3(0.00, 0.00, 0.00);
    } else {
        // Rainbow
        a = vec3(0.5); b = vec3(0.5);
        c = vec3(1.0); d = vec3(0.00, 0.33, 0.67);
    }
    return a + b * cos(6.28318 * (c * t + d));
}

// Single mandelbox iteration step.
void mandelboxStep(inout vec3 z, vec3 c, inout float DE,
                   float foldLimit, float foldValue,
                   float mR2, float fR2, float scale) {
    // Box fold: reflect about ±foldLimit on each axis.
    if (z.x >  foldLimit) z.x =  foldValue - z.x;
    if (z.x < -foldLimit) z.x = -foldValue - z.x;
    if (z.y >  foldLimit) z.y =  foldValue - z.y;
    if (z.y < -foldLimit) z.y = -foldValue - z.y;
    if (z.z >  foldLimit) z.z =  foldValue - z.z;
    if (z.z < -foldLimit) z.z = -foldValue - z.z;

    // Sphere fold.
    float r2 = dot(z, z);
    if (r2 < mR2) {
        float k = fR2 / mR2;
        z  *= k;
        DE *= k;
    } else if (r2 < fR2) {
        float k = fR2 / r2;
        z  *= k;
        DE *= k;
    }

    z  = z * scale + c;
    DE = DE * abs(scale) + 1.0;
}

// Mandelbox distance estimator.
float mandelboxDE(vec3 pos) {
    int maxIter = int(uIterations);
    vec3  z  = pos;
    float DE = 1.0;

    for (int i = 0; i < 20; i++) {   // compile-time ceiling
        if (i >= maxIter) break;
        mandelboxStep(z, pos, DE, uFoldLimit, uFoldValue, uMinR2, uFixedR2, uScale);
    }
    return length(z) / abs(DE);
}

// Normal via forward differences (4 evaluations).
vec3 getNormal(vec3 pos) {
    float eps = 0.001;
    float d = mandelboxDE(pos);
    return normalize(vec3(
        mandelboxDE(pos + vec3(eps, 0.0, 0.0)) - d,
        mandelboxDE(pos + vec3(0.0, eps, 0.0)) - d,
        mandelboxDE(pos + vec3(0.0, 0.0, eps)) - d
    ));
}

// Three-light Blinn-Phong shading.
vec3 calculateLighting(vec3 position, vec3 normal, vec3 baseColor, vec3 cameraPos) {
    vec3 viewDir = normalize(cameraPos - position);

    // Key light (warm white from upper-right-front).
    vec3 l1 = normalize(vec3(3.0, 5.0, 4.0) - position);
    float d1 = max(dot(normal, l1), 0.0);
    float s1 = pow(max(dot(normal, normalize(l1 + viewDir)), 0.0), 48.0);

    // Fill light (cool blue from left).
    vec3 l2 = normalize(vec3(-4.0, 2.0, -1.0) - position);
    float d2 = max(dot(normal, l2), 0.0) * 0.35;

    // Rim light (back-top).
    vec3 l3 = normalize(vec3(0.0, -3.0, -5.0) - position);
    float d3 = max(dot(normal, l3), 0.0) * 0.2;

    vec3 col  = baseColor * (0.08 + d1 * 0.7 + d2 + d3);
    col      += vec3(0.9, 0.95, 1.0) * s1 * 0.4;
    return col;
}

// Ray march: sphere trace toward the mandelbox.
// Returns vec4(hitPos, stepCount) on hit, vec4(0,0,0,-1) on miss.
vec4 rayMarch(vec3 origin, vec3 direction) {
    float totalDist = 0.0;
    int   maxSteps  = int(uMaxSteps);
    float minDist   = 0.001 / max(uZoom, 0.1);

    for (int i = 0; i < 150; i++) {
        if (i >= maxSteps) break;
        vec3  pos  = origin + totalDist * direction;
        float dist = mandelboxDE(pos);

        if (dist < minDist) {
            return vec4(pos, float(i));
        }

        totalDist += dist * 0.9;   // conservative step

        if (totalDist > 20.0) break;
    }
    return vec4(0.0, 0.0, 0.0, -1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    // Normalized coords: origin at center, y-up, aspect-corrected.
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    // Build camera from rotation + zoom.
    mat3 rot     = rotationMatrix(uRotation);
    vec3 camPos  = rot * vec3(0.0, 0.0, 3.0 / max(uZoom, 0.1));
    vec3 forward = normalize(-camPos);
    vec3 right   = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up      = cross(forward, right);
    vec3 rayDir  = normalize(forward + uv.x * right + uv.y * up);

    vec4 hit = rayMarch(camPos, rayDir);

    vec3 color;
    float alpha;

    if (hit.w >= 0.0) {
        // Surface hit.
        vec3  normal    = getNormal(hit.xyz);
        float t         = hit.w / max(uIterations, 1.0);
        vec3  baseColor = palette(t, uColorScheme);
        color           = calculateLighting(hit.xyz, normal, baseColor, camPos);

        // Distance fog.
        float dist = length(hit.xyz - camPos);
        float fog  = exp(-dist * 0.12);
        color      = mix(vec3(0.02, 0.02, 0.04), color, fog);
        alpha      = 1.0;
    } else {
        // Background: subtle gradient.
        vec3 bgTop = vec3(0.05, 0.05, 0.12);
        vec3 bgBot = vec3(0.02, 0.02, 0.04);
        color = mix(bgBot, bgTop, uv.y * 0.5 + 0.5);
        alpha = mix(1.0, 0.0, step(0.5, uTransparentBg));
    }

    fragColor = vec4(linearToSRGB(color), alpha);
}
