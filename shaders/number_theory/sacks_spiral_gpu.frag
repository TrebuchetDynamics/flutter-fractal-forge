#include <flutter/runtime_effect.glsl>

precision highp float;
precision highp int;

uniform vec2 uResolution;
uniform vec2 uPan;
uniform float uZoom;
uniform float uMarks;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

const float TAU = 6.283185307179586;
const int MAX_N = 1002001;

bool divides(int n, int d) {
  return (n / d) * d == n;
}

bool isPrime(int n) {
  if (n < 4) return n >= 2;
  if (divides(n, 2) || divides(n, 3)) return false;
  for (int d = 5; d <= 1001; d += 6) {
    if (d * d > n) break;
    if (divides(n, d)) return false;
    int next = d + 2;
    if (next * next <= n && divides(n, next)) return false;
  }
  return true;
}

int integerRoot(int n, float radius) {
  int k = int(radius);
  if (k * k > n) return k - 1;
  if ((k + 1) * (k + 1) <= n) return k + 1;
  return k;
}

vec2 dotDirection(float turns) {
  // Skia's approximate trig can displace outer dots by >0.1 plane units.
  // Reduce to the nearest quadrant and use Taylor polynomials on ±π/4.
  float quadrant = floor(4.0 * turns + 0.5);
  float a = (TAU / 4.0) * (4.0 * turns - quadrant);
  float a2 = a * a;
  float x = 1.0 + a2 * (-0.5 + a2 * (1.0 / 24.0 + a2 * (-1.0 / 720.0 + a2 / 40320.0)));
  float y = a * (1.0 + a2 * (-1.0 / 6.0 + a2 * (1.0 / 120.0 - a2 / 5040.0)));
  if (quadrant == 1.0) return vec2(-y, x);
  if (quadrant == 2.0) return vec2(-x, -y);
  if (quadrant == 3.0) return vec2(y, -x);
  return vec2(x, y);
}

vec3 primeColor() {
  if (uColorScheme == 0.0) return vec3(1.0, 0.65, 0.29);
  if (uColorScheme == 1.0) return vec3(0.42, 0.94, 1.0);
  if (uColorScheme == 2.0) return vec3(0.88, 0.56, 1.0);
  return vec3(0.94);
}

void main() {
  float pixelsPerUnit = uZoom * min(uResolution.x, uResolution.y) / 203.0;
  vec2 p = (FlutterFragCoord().xy - 0.5 * uResolution) / pixelsPerUnit
    + 203.0 * uPan;
  p.y = -p.y;
  float r = length(p);
  vec4 bg = uTransparentBg > 0.5 ? vec4(0.0) : vec4(0.018, 0.025, 0.048, 1.0);
  fragColor = bg;
  if (r > 1001.0) return;

  float turn = fract(r == 0.0 ? 0.0 : atan(p.y, p.x) / TAU);
  float arm = floor(r - turn + 0.5);
  float radius = max(0.35, 0.75 / pixelsPerUnit);
  float feather = 0.5 / pixelsPerUnit;
  float bestDistance2 = (radius + feather) * (radius + feather);
  int best = 0;
  bool square = false;
  // Check the three nearby turns and three consecutive indices per turn.
  for (int i = -1; i <= 1; i++) {
    float s = arm + float(i) + turn;
    if (s <= 0.0) continue;
    int nearest = int(floor(s * s + 0.5));
    for (int j = -1; j <= 1; j++) {
      int n = nearest + j;
      if (n < 1 || n > MAX_N) continue;
      float root = sqrt(float(n));
      int k = integerRoot(n, root);
      int remainder = n - k * k;
      // Rationalize sqrt(n) - k to preserve its small fractional part.
      float fraction = float(remainder) / (root + float(k));
      vec2 delta = p - root * dotDirection(fraction);
      float distance2 = dot(delta, delta);
      if (distance2 < bestDistance2) {
        bestDistance2 = distance2;
        best = n;
        square = remainder == 0;
      }
    }
  }
  if (best == 0) return;

  // Only classify the winning dot, and only if it covers this pixel.
  bool markedSquare = uMarks > 0.5 && square;
  bool lit = markedSquare || isPrime(best);
  vec3 color = primeColor() * (lit ? 1.0 : 0.45);
  if (markedSquare) {
    color = uColorScheme == 0.0 ? vec3(0.42, 0.94, 1.0) : vec3(1.0, 0.43, 0.21);
  }
  float coverage = 1.0 - smoothstep(radius - feather, radius + feather, sqrt(bestDistance2));
  float alpha = coverage * (lit ? 0.97 : 0.24);
  fragColor = vec4(color * alpha, alpha) + bg * (1.0 - alpha);
}
