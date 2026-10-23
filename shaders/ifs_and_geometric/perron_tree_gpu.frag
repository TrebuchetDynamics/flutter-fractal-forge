#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
uniform float uLeaves;
uniform float uShapeY;
uniform float uAngle;
uniform float uGlow;
uniform float uStyle;
uniform float uHue;
uniform float uTransparentBackground;
uniform float uOffsets[32];
out vec4 fragColor;

vec2 rotatePoint(vec2 p, float a) {
  float c = cos(a), s = sin(a);
  return vec2(c*p.x - s*p.y, s*p.x + c*p.y);
}

void main() {
  const float halfBase = 0.5773502691896258;
  float zoom = clamp(uZoom, 1e-9, 1e12);
  float scale = 3.0 / (max(1.0, min(uResolution.x, uResolution.y)) * zoom);
  vec2 p = (FlutterFragCoord().xy - .5*uResolution) * scale + uCenter;
  p = rotatePoint(p, -uAngle * 0.017453292519943295);
  // Bound filtering width: distant, subpixel geometry must not become a flat fill.
  float aa = clamp(.75 * scale, 1e-7, .025);
  // No finite leaf extends this far. Avoid huge-coordinate filtering and
  // exponential overflow on backends with aggressive intermediate precision.
  if (max(abs(p.x), abs(p.y)) > 2.0) {
    fragColor = uTransparentBackground > .5 ? vec4(0.0) : vec4(.012,.018,.035,1.0);
    return;
  }
  float coverage = 0.0, light = 0.0, weight = 0.0;
  vec3 color = vec3(0.0), glowColor = vec3(0.0);
  int leaves = int(uLeaves);
  for (int fan = 0; fan < 3; fan++) {
    vec2 q = rotatePoint(p, -float(fan)*2.0943951023931955);
    float y = q.y + uShapeY;
    for (int i = 0; i < 32; i++) {
      if (i >= leaves) break;
      float leftSlope = -halfBase + 2.0*halfBase*float(i)/uLeaves;
      float rightSlope = leftSlope + 2.0*halfBase/uLeaves;
      float x = q.x - uOffsets[i];
      // Signed edge distances of the original unit-height triangle. Translation
      // never shortens its line segments. Glow is separate from this coverage.
      float d = max(max(-y, y-1.0), max((leftSlope*y-x)/sqrt(1.0+leftSlope*leftSlope),
          (x-rightSlope*y)/sqrt(1.0+rightSlope*rightSlope)));
      float fill = 1.0-smoothstep(-aa, aa, d);
      coverage = max(coverage, fill);
      vec3 tint = .55 + .45*cos(6.28318530718*(vec3(0.0,.33,.67) + float(i)/uLeaves + float(fan)*.13 + uHue));
      color += fill * tint;
      weight += fill;
      if (uStyle > .5) {
        float halo = exp(-min(abs(d)/(.003+.012*uGlow), 40.0))*uGlow*.22;
        glowColor = max(glowColor, halo*tint);
        light = max(light, halo);
      }
    }
  }
  // Average overlapping directions; extra leaves must not burn the core white.
  color = color/max(weight, 1e-6)*coverage;
  if (uStyle < .5) color = vec3(.2,.8,.9)*coverage;
  else color += glowColor*(1.0-coverage);
  color = clamp(color, 0.0, 1.0);
  float alpha = clamp(coverage + light*(1.0-coverage), 0.0, 1.0);
  vec3 background = vec3(.012,.018,.035);
  if (uTransparentBackground > .5) {
    fragColor = vec4(min(color, vec3(alpha)), alpha);
  } else {
    fragColor = vec4(color + background*(1.0-alpha), 1.0);
  }
}
