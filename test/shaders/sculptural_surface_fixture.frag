#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uResolution;
uniform float uCase;
out vec4 fragColor;

vec3 linearToSRGB(vec3 lin) {
    lin = clamp(lin, 0.0, 1.0);
    bvec3 cutoff = lessThan(lin, vec3(0.0031308));
    vec3 hi = 1.055 * pow(max(lin, vec3(0.0031308)), vec3(1.0 / 2.4)) - 0.055;
    vec3 lo = lin * 12.92;
    return mix(hi, lo, vec3(cutoff));
}

// BEGIN GENERATED SURFACE LIGHTING
// Linear-light sculptural material. Consumers perform the display transfer once.
bool surfaceFinite(float value) {
    return value >= -1.0e20 && value <= 1.0e20;
}

vec3 surfaceDirection(vec3 value, vec3 fallback) {
    float squared = dot(value, value);
    if (!surfaceFinite(squared) || squared < 1.0e-12) return fallback;
    return value * inversesqrt(squared);
}

const vec3 SCULPTURAL_STONE = vec3(0.305, 0.285, 0.245);

vec3 sculpturalSurface(vec3 position, vec3 normal, vec3 viewDirection,
                       vec3 baseColor, float ao, float depth) {
    vec3 key = normalize(vec3(0.6, 0.8, 1.0));
    vec3 fill = normalize(vec3(-0.8, 0.4, 0.2));
    vec3 n = surfaceDirection(normal, vec3(0.0, 0.0, 1.0));
    vec3 v = surfaceDirection(viewDirection, vec3(0.0, 0.0, 1.0));
    vec3 halfDirection = surfaceDirection(key + v, key);
    float visibility = surfaceFinite(ao) ? clamp(ao, 0.0, 1.0) : 1.0;
    float diffuse = max(dot(n, key), 0.0);
    float softFill = 0.5 + 0.5 * dot(n, fill);
    float specular = pow(max(dot(n, halfDirection), 0.0), 40.0)
                   * step(0.0, dot(n, key));
    // Broad mineral variation, independent of ray steps or iterations.
    float tint = clamp(0.18 * position.y + 0.08 * position.x, -0.5, 0.5);
    vec3 material = baseColor * (1.0 + tint * vec3(0.75, 0.38, 0.04));
    vec3 color = material * (0.12 + 0.72 * diffuse + 0.20 * softFill)
               * (0.75 + 0.25 * visibility);
    color += vec3(0.24 * specular); // neutral dielectric highlight
    float distance = surfaceFinite(depth) ? max(depth, 0.0) : 0.0;
    float fog = exp(-0.055 * distance);
    return mix(vec3(0.025), color, fog);
}
// END GENERATED SURFACE LIGHTING

void main() {
    vec3 key = normalize(vec3(0.6, 0.8, 1.0));
    vec3 normal = uCase == 1.0 ? -key : key;
    vec3 base = uCase == 2.0 ? vec3(0.0) : vec3(0.25);
    float ao = uCase == 3.0 ? -2.0 : uCase == 4.0 ? 2.0 : uCase == 5.0 ? 0.0 : 1.0;
    vec3 color = sculpturalSurface(vec3(0.0), normal, key, base, ao, 0.0);
    fragColor = vec4(linearToSRGB(color), 1.0);
}
