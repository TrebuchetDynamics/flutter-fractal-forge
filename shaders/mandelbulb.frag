#include <flutter/runtime_effect.glsl>

precision highp float;

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

// Precomputed rotation matrix (computed once in main)
mat3 gRotation;

// Combined rotation matrix - more efficient than 3 separate matrices
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

// Mandelbulb distance estimation - optimized
float mandelbulbDE(vec3 pos, int maxIter) {
    vec3 z = pos;
    float dr = 1.0;
    float r = 0.0;
    
    for (int i = 0; i < 50; i++) {
        if (i >= maxIter) break;
        
        r = length(z);
        if (r > uBailout) break;
        
        // Spherical coordinates
        float theta = acos(z.z / r);
        float phi = atan(z.y, z.x);
        
        // Power derivation
        float powR = pow(r, uPower - 1.0);
        dr = powR * uPower * dr + 1.0;
        
        // Scale and rotate
        float zr = powR * r;  // r^power
        theta *= uPower;
        phi *= uPower;
        
        // Back to cartesian
        float sinTheta = sin(theta);
        z = zr * vec3(sinTheta * cos(phi), sinTheta * sin(phi), cos(theta)) + pos;
    }
    
    return 0.5 * log(r) * r / dr;
}

// Mandelbox distance estimation - optimized with reduced branching
float mandelboxDE(vec3 pos, int maxIter) {
    vec3 z = pos;
    float r = 0.0;
    float scale = 2.0;
    
    for (int i = 0; i < 50; i++) {
        if (i >= maxIter) break;
        
        // Box fold - branchless using clamp
        z = clamp(z, -1.0, 1.0) * 2.0 - z;
        
        // Sphere fold
        r = dot(z, z);
        // Branchless: if r < 0.25, multiply by 4; if r < 1, divide by r; else keep
        float factor = max(1.0 / max(r, 0.25), 1.0);
        factor = min(factor, 4.0);
        z *= factor;
        
        // Scale and translate
        z = z * scale + pos;
        
        if (length(z) > uBailout) break;
    }
    
    return length(z) * pow(scale, -float(maxIter));
}

// 3D Julia distance estimation
float juliaDE(vec3 pos, int maxIter) {
    vec3 z = pos;
    vec3 c = vec3(0.285, 0.01, 0.0);
    float r = 0.0;
    float dr = 1.0;
    
    for (int i = 0; i < 50; i++) {
        if (i >= maxIter) break;
        
        r = length(z);
        if (r > uBailout) break;
        
        // Quaternion-like multiplication
        float x = z.x * z.x - z.y * z.y - z.z * z.z + c.x;
        float y = 2.0 * z.x * z.y + c.y;
        float zCoord = 2.0 * z.x * z.z + c.z;
        
        z = vec3(x, y, zCoord);
        dr = 2.0 * r * dr + 1.0;
    }
    
    return 0.5 * log(r) * r / dr;
}

// Sierpinski tetrahedron - optimized vertex selection
float sierpinskiDE(vec3 pos, int maxIter) {
    vec3 z = pos;
    
    // Precomputed tetrahedron vertices
    const vec3 v0 = vec3(1.0, 1.0, 1.0);
    const vec3 v1 = vec3(-1.0, -1.0, 1.0);
    const vec3 v2 = vec3(-1.0, 1.0, -1.0);
    const vec3 v3 = vec3(1.0, -1.0, -1.0);
    
    float scale = 1.0;
    int loopLimit = maxIter / 3;
    
    for (int i = 0; i < 15; i++) {
        if (i >= loopLimit) break;
        
        // Find closest vertex using branchless min
        vec3 closest = v0;
        float minDist = dot(z - v0, z - v0);
        
        float d1 = dot(z - v1, z - v1);
        float d2 = dot(z - v2, z - v2);
        float d3 = dot(z - v3, z - v3);
        
        // Branchless closest selection
        closest = mix(closest, v1, step(d1, minDist));
        minDist = min(minDist, d1);
        closest = mix(closest, v2, step(d2, minDist));
        minDist = min(minDist, d2);
        closest = mix(closest, v3, step(d3, minDist));
        
        z = z * 2.0 - closest;
        scale *= 0.5;
    }
    
    return length(z) * scale;
}

// Distance function dispatcher - optimized with step-based blending
float getDistance(vec3 pos) {
    int maxIter = int(uIterations);
    int type = int(uFractalType);
    
    // For simple cases, use direct selection (most common path)
    if (type == 0) return mandelbulbDE(pos, maxIter);
    if (type == 1) return mandelboxDE(pos, maxIter);
    if (type == 2) return juliaDE(pos, maxIter);
    return sierpinskiDE(pos, maxIter);
}

// Raymarching with LOD and adaptive step
vec4 rayMarch(vec3 origin, vec3 direction) {
    float totalDistance = 0.0;
    int iterations = 0;
    
    // LOD: Fewer steps when zoomed out
    float lodFactor = clamp(uZoom * 0.5, 0.5, 1.0);
    // SkSL doesn't support max(int, int), use float version
    float fMaxSteps = max(uSteps * lodFactor, 10.0);
    int maxSteps = int(fMaxSteps);
    
    // Adaptive minimum distance based on zoom
    float minDist = 0.001 / max(uZoom, 0.1);
    
    vec3 pos = origin;
    
    for (int i = 0; i < 150; i++) {
        if (i >= maxSteps) break;
        
        iterations = i;
        pos = origin + totalDistance * direction;
        float distance = getDistance(pos);
        
        if (distance < minDist) {
            // Surface hit - return position and iteration data
            return vec4(pos, float(iterations));
        }
        
        // Adaptive step: larger steps when far from surface
        totalDistance += distance * 0.9;  // Slightly conservative for safety
        
        if (totalDistance > 20.0) break;
    }
    
    return vec4(0.0, 0.0, 0.0, -1.0);  // Miss indicator
}

// Compute normal using forward differences (4 samples instead of 6)
vec3 getNormal(vec3 pos) {
    float eps = 0.001;
    float d = getDistance(pos);
    return normalize(vec3(
        getDistance(pos + vec3(eps, 0.0, 0.0)) - d,
        getDistance(pos + vec3(0.0, eps, 0.0)) - d,
        getDistance(pos + vec3(0.0, 0.0, eps)) - d
    ));
}

// Branchless color scheme selection
vec3 getColor(float t, int scheme) {
    vec3 fire = mix(vec3(0.1, 0.0, 0.0), vec3(1.0, 0.3, 0.0), t);
    vec3 ocean = mix(vec3(0.0, 0.1, 0.2), vec3(0.0, 0.8, 1.0), t);
    vec3 psychedelic = vec3(
        sin(t * 6.28) * 0.5 + 0.5,
        sin(t * 6.28 + 2.09) * 0.5 + 0.5,
        sin(t * 6.28 + 4.19) * 0.5 + 0.5
    );
    vec3 gray = vec3(t);
    
    float s0 = step(1.0, float(scheme));
    float s1 = step(2.0, float(scheme));
    float s2 = step(3.0, float(scheme));
    
    vec3 result = fire;
    result = mix(result, ocean, s0 * (1.0 - s1));
    result = mix(result, psychedelic, s1 * (1.0 - s2));
    result = mix(result, gray, s2);
    
    return result;
}

// Optimized lighting with single light source
vec3 calculateLighting(vec3 position, vec3 normal, vec3 color) {
    vec3 lightDir = normalize(vec3(5.0, 5.0, 5.0) - position);
    vec3 viewDir = normalize(-position);
    vec3 halfDir = normalize(lightDir + viewDir);
    
    // Combined Blinn-Phong
    float diffuse = max(dot(normal, lightDir), 0.0);
    float specular = pow(max(dot(normal, halfDir), 0.0), 32.0);
    
    return color * (0.1 + diffuse * 0.8 + specular * 0.3);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    // Compute rotation matrix once
    gRotation = rotationMatrix(uRotation);
    
    // Camera setup
    vec3 cameraPos = gRotation * vec3(0.0, 0.0, 3.0 / max(uZoom, 0.1));
    
    vec3 forward = normalize(-cameraPos);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    
    vec3 direction = normalize(forward + uv.x * right + uv.y * up);
    
    vec4 hit = rayMarch(cameraPos, direction);
    
    if (hit.w >= 0.0) {
        // Hit
        vec3 normal = getNormal(hit.xyz);
        float t = hit.w / uIterations;
        vec3 color = getColor(t, int(uColorScheme));
        color = calculateLighting(hit.xyz, normal, color);
        
        // Distance fog
        float dist = length(hit.xyz - cameraPos);
        float fog = exp(-dist * 0.15);
        color = mix(vec3(0.02), color, fog);
        
        fragColor = vec4(color, 1.0);
    } else {
        // Background
        vec3 bgColor = mix(vec3(0.02), vec3(0.05, 0.05, 0.1), uv.y * 0.5 + 0.5);
        float alpha = mix(1.0, 0.0, step(0.5, uTransparentBg));
        fragColor = vec4(bgColor, alpha);
    }
}
