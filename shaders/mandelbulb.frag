#include <flutter/runtime_effect.glsl>

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

// Rotation matrices
mat3 rotateX(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, -s,
        0.0, s, c
    );
}

mat3 rotateY(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, 0.0, s,
        0.0, 1.0, 0.0,
        -s, 0.0, c
    );
}

mat3 rotateZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, -s, 0.0,
        s, c, 0.0,
        0.0, 0.0, 1.0
    );
}

// Mandelbulb distance estimation
float mandelbulbDE(vec3 pos) {
    vec3 z = pos;
    float dr = 1.0;
    float r = 0.0;
    int iterations = 0;
    int maxIter = int(uIterations);
    
    for (int i = 0; i < 100; i++) {
        iterations = i;
        if (i >= maxIter) break;
        
        r = length(z);
        if (r > uBailout) break;
        
        // Convert to polar coordinates
        float theta = acos(z.z / r);
        float phi = atan(z.y, z.x);
        dr = pow(r, uPower - 1.0) * uPower * dr + 1.0;
        
        // Scale and rotate the point
        float zr = pow(r, uPower);
        theta = theta * uPower;
        phi = phi * uPower;
        
        // Convert back to cartesian coordinates
        z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
        z += pos;
    }
    
    return 0.5 * log(r) * r / dr;
}

// Mandelbox distance estimation
float mandelboxDE(vec3 pos) {
    vec3 z = pos;
    float r = 0.0;
    int iterations = 0;
    int maxIter = int(uIterations);
    
    for (int i = 0; i < 100; i++) {
        iterations = i;
        if (i >= maxIter) break;
        
        // Box fold
        if (abs(z.x) > 1.0) z.x = sign(z.x) * (2.0 - abs(z.x));
        if (abs(z.y) > 1.0) z.y = sign(z.y) * (2.0 - abs(z.y));
        if (abs(z.z) > 1.0) z.z = sign(z.z) * (2.0 - abs(z.z));
        
        // Sphere fold
        r = length(z);
        if (r < 0.5) {
            z = z * 4.0;
        } else if (r < 1.0) {
            z = z / (r * r);
        }
        
        // Scale and translate
        z = z * 2.0 + pos;
        
        r = length(z);
        if (r > uBailout) break;
    }
    
    return length(z) * pow(2.0, -float(iterations));
}

// Julia set distance estimation
float juliaDE(vec3 pos) {
    vec3 z = pos;
    vec3 c = vec3(0.285, 0.01, 0.0);
    float r = 0.0;
    int iterations = 0;
    int maxIter = int(uIterations);
    
    for (int i = 0; i < 100; i++) {
        iterations = i;
        if (i >= maxIter) break;
        
        r = length(z);
        if (r > uBailout) break;
        
        // Julia set iteration
        float x = z.x * z.x - z.y * z.y - z.z * z.z + c.x;
        float y = 2.0 * z.x * z.y + c.y;
        float z_coord = 2.0 * z.x * z.z + c.z;
        
        z = vec3(x, y, z_coord);
    }
    
    return 0.5 * log(r) * r / pow(r, float(iterations) * 0.5);
}

// Sierpinski tetrahedron distance estimation
float sierpinskiDE(vec3 pos) {
    vec3 z = pos;
    int iterations = 0;
    int maxIter = int(uIterations);
    
    for (int i = 0; i < 20; i++) {
        iterations = i;
        if (i >= maxIter / 3) break;
        
        // Tetrahedron vertices
        vec3 a1 = vec3(1.0, 1.0, 1.0);
        vec3 a2 = vec3(-1.0, -1.0, 1.0);
        vec3 a3 = vec3(-1.0, 1.0, -1.0);
        vec3 a4 = vec3(1.0, -1.0, -1.0);
        
        // Find closest vertex
        float d1 = dot(z - a1, z - a1);
        float d2 = dot(z - a2, z - a2);
        float d3 = dot(z - a3, z - a3);
        float d4 = dot(z - a4, z - a4);
        
        vec3 closest = a1;
        float minDist = d1;
        
        if (d2 < minDist) {
            minDist = d2;
            closest = a2;
        }
        if (d3 < minDist) {
            minDist = d3;
            closest = a3;
        }
        if (d4 < minDist) {
            minDist = d4;
            closest = a4;
        }
        
        z = z * 2.0 - closest;
    }
    
    return length(z) * pow(2.0, -float(iterations));
}

// Main distance estimation function
float getDistance(vec3 pos) {
    int type = int(uFractalType);
    if (type == 0) {
        return mandelbulbDE(pos);
    } else if (type == 1) {
        return mandelboxDE(pos);
    } else if (type == 2) {
        return juliaDE(pos);
    } else if (type == 3) {
        return sierpinskiDE(pos);
    }
    return mandelbulbDE(pos);
}

struct Hit {
    bool hit;
    float distance;
    vec3 position;
    vec3 normal;
    int iterations;
};

// Raymarching
Hit rayMarch(vec3 origin, vec3 direction) {
    float totalDistance = 0.0;
    int iterations = 0;
    int maxSteps = int(uSteps);
    if (maxSteps < 1) {
        maxSteps = 1;
    }
    
    vec3 pos = origin;
    
    for (int i = 0; i < 200; i++) {
        iterations = i;
        if (i >= maxSteps) {
            break;
        }
        pos = origin + totalDistance * direction;
        float distance = getDistance(pos);
        
        if (distance < 0.001) {
            // Calculate normal
            vec2 epsilon = vec2(0.001, 0.0);
            vec3 normal = normalize(vec3(
                getDistance(pos + epsilon.xyy) - getDistance(pos - epsilon.xyy),
                getDistance(pos + epsilon.yxy) - getDistance(pos - epsilon.yxy),
                getDistance(pos + epsilon.yyx) - getDistance(pos - epsilon.yyx)
            ));
            
            return Hit(true, totalDistance, pos, normal, iterations);
        }
        
        totalDistance += distance;
        if (totalDistance > 20.0) break;
    }
    
    return Hit(false, totalDistance, vec3(0.0), vec3(0.0), iterations);
}

// Color schemes
vec3 getColor(float iterations, vec3 position, vec3 normal) {
    float t = iterations / uIterations;
    int scheme = int(uColorScheme);
    
    if (scheme == 0) {
        // Fire colors
        return mix(vec3(0.1, 0.0, 0.0), vec3(1.0, 0.3, 0.0), t);
    } else if (scheme == 1) {
        // Ocean colors
        return mix(vec3(0.0, 0.1, 0.2), vec3(0.0, 0.8, 1.0), t);
    } else if (scheme == 2) {
        // Psychedelic
        return vec3(sin(t * 6.28), sin(t * 6.28 + 2.09), sin(t * 6.28 + 4.19));
    } else {
        // Grayscale
        return vec3(t);
    }
}

// Lighting
vec3 calculateLighting(vec3 position, vec3 normal, vec3 color) {
    vec3 lightPos = vec3(5.0, 5.0, 5.0);
    vec3 lightDir = normalize(lightPos - position);
    vec3 viewDir = normalize(-position);
    vec3 reflectDir = reflect(-lightDir, normal);
    
    // Ambient
    float ambient = 0.1;
    
    // Diffuse
    float diffuse = max(dot(normal, lightDir), 0.0);
    
    // Specular
    float specular = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    
    vec3 lightColor = vec3(1.0);
    return color * (ambient + diffuse * lightColor + specular * lightColor);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uResolution) / uResolution.y;
    // Fix aspect ratio calculation if needed, but the above centers 0,0 and scales by height
    // Actually the standard is usually (2.0*fragCoord - uResolution.xy)/uResolution.y
    // Let's stick to standard normalized coordinates centered at screen
    
    uv = (fragCoord - 0.5 * uResolution) * 2.0 / uResolution.y;

    // Camera setup
    vec3 cameraPos = vec3(0.0, 0.0, 3.0 / uZoom);
    mat3 rotation = rotateX(uRotation.x) * rotateY(uRotation.y) * rotateZ(uRotation.z);
    cameraPos = rotation * cameraPos;
    
    vec3 target = vec3(0.0);
    vec3 forward = normalize(target - cameraPos);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    
    vec3 direction = normalize(forward + uv.x * right + uv.y * up);
    
    Hit hit = rayMarch(cameraPos, direction);
    
    if (hit.hit) {
        vec3 color = getColor(float(hit.iterations), hit.position, hit.normal);
        color = calculateLighting(hit.position, hit.normal, color);
        
        // Add fog effect
        float fog = exp(-hit.distance * 0.1);
        color = mix(vec3(0.02), color, fog);
        fragColor = vec4(color, 1.0);
    } else {
        // Background gradient
        // Use uv.y for gradient
        vec3 bgColor = mix(vec3(0.02), vec3(0.05, 0.05, 0.1), uv.y * 0.5 + 0.5);
        float alpha = 1.0;
        if (uTransparentBg > 0.5) {
            alpha = 0.0;
        }
        fragColor = vec4(bgColor, alpha);
    }
}
