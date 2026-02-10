#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float uTime;          // 0
uniform vec2  uResolution;    // 1-2
uniform vec2  uCenter;        // 3-4
uniform float uZoom;          // 5
uniform float uIterations;    // 6
uniform float uBailout;       // 7
uniform float uColorScheme;   // 8
uniform float uTransparentBg; // 9

out vec4 fragColor;

vec3 palette(float t, int scheme) {
  if (scheme == 0) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.4)),0.5+0.5*cos(6.28318*(t+0.7)));
  } else if (scheme == 1) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.5)),0.5+0.5*cos(6.28318*(t+0.3)),0.5+0.5*cos(6.28318*(t+0.0)));
  } else if (scheme == 2) {
    return vec3(0.5+0.5*cos(6.28318*(t+0.0)),0.5+0.5*cos(6.28318*(t+0.33)),0.5+0.5*cos(6.28318*(t+0.67)));
  } else if (scheme == 3) {
    float g = 0.5+0.5*cos(6.28318*t); return vec3(g);
  }

  float s = float(scheme);
  vec3 a = 0.55 + 0.15 * sin(vec3(1.0, 2.0, 3.0) * (0.37 * s + 0.1));
  vec3 b = 0.45 + 0.25 * cos(vec3(1.7, 2.3, 2.9) * (0.29 * s + 0.2));
  vec3 c = 1.0  + 0.80 * sin(vec3(0.8, 1.3, 1.7) * (0.11 * s + 0.3));
  vec3 d = fract(sin(vec3(12.9898, 78.233, 37.719) * (s + 0.5)) * 43758.5453);
  vec3 col = a + b * cos(6.28318 * (c * t + d));
  return clamp(col, 0.0, 1.0);
}


void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  float scale = min(uResolution.x, uResolution.y);
  vec2 uv = (fragCoord - 0.5*uResolution) / max(1.0, scale);
  vec2 c = uv / max(0.000001, uZoom) + uCenter;
  vec2 z = vec2(0.0);

  float bailoutSq = uBailout * uBailout;
  const int MAX_ITERS = 500;
  int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)));
  int it = 0;

  for (int j = 0; j < MAX_ITERS; j++) {
    if (j >= target) { it = target; break; }

    // Celtic: z_{n+1} = (|Re(z_n^2)| + i*Im(z_n^2)) + c
    float x2 = z.x*z.x - z.y*z.y;
    float y2 = 2.0*z.x*z.y;
    z = vec2(abs(x2) + c.x, y2 + c.y);

    if (dot(z, z) > bailoutSq) { it = j; break; }
    it = j + 1;
  }

  if (it >= target) {
    fragColor = (uTransparentBg > 0.5) ? vec4(0.0) : vec4(0.0,0.0,0.0,1.0);
    return;
  }

  float mag2 = max(1e-12, dot(z, z));
  float smoothVal = float(it) - log2(log2(mag2));
  float t = fract(smoothVal / max(1.0, uIterations) + uTime*0.0001);
  vec3 color = palette(t, int(uColorScheme));
  fragColor = vec4(color, 1.0);
}
