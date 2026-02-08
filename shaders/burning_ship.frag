#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uIterations;
uniform float uBailout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 palette(float t, float scheme) {
    if (scheme < 0.5) {
        return vec3(0.2 + 0.8 * t, 0.1 + 0.3 * t, 0.05 + 0.2 * t);
    } else if (scheme < 1.5) {
        return vec3(0.05 + 0.3 * t, 0.2 + 0.7 * t, 0.4 + 0.5 * t);
    } else if (scheme < 2.5) {
        return vec3(0.5 + 0.5 * sin(6.2831 * t + uTime * 0.2),
                    0.5 + 0.5 * sin(6.2831 * t + 2.0),
                    0.5 + 0.5 * sin(6.2831 * t + 4.0));
    }
    return vec3(t);
}

void main() {
    vec2 uv = (FlutterFragCoord().xy - 0.5 * uResolution.xy) / min(uResolution.x, uResolution.y);
    vec2 c = uv / max(uZoom, 0.0001) + uCenter;
    vec2 z = vec2(0.0);
    float iter = 0.0;
    float maxIter = max(uIterations, 1.0);

    for (int i = 0; i < 1000; i++) {
        if (float(i) >= maxIter) {
            break;
        }
        if (dot(z, z) > uBailout * uBailout) {
            iter = float(i);
            break;
        }
        vec2 zAbs = vec2(abs(z.x), abs(z.y));
        z = vec2(
            zAbs.x * zAbs.x - zAbs.y * zAbs.y + c.x,
            2.0 * zAbs.x * zAbs.y + c.y
        );
        iter = float(i);
    }

    float t = iter / maxIter;
    vec3 color = palette(t, uColorScheme);

    // AR overlay mode: make the interior of the set transparent.
    float alpha = 1.0;
    if (uTransparentBg > 0.5) {
        bool inside = iter >= (maxIter - 1.0);
        alpha = inside ? 0.0 : 1.0;
    }

    fragColor = vec4(color, alpha);
}
