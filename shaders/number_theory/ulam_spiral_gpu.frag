#include <flutter/runtime_effect.glsl>

precision highp float;
precision highp int;

uniform vec2 uResolution;
uniform vec2 uPan;
uniform float uZoom;
uniform float uStartValue;
uniform float uPattern;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

int remainder(int n, int d) {
  return n - (n / d) * d;
}

int ulamIndex(int x, int y, int ring) {
  // Walk backwards from the last square (bottom-right) around the ring.
  int side = 2 * ring;
  int corner = (side + 1) * (side + 1);
  if (y == -ring) return corner - (ring - x);
  if (x == -ring) return corner - side - (ring + y);
  if (y == ring) return corner - 2 * side - (ring + x);
  return corner - 3 * side - (ring - y);
}

bool isPrime(int n) {
  if (n < 4) return n >= 2;
  if (remainder(n, 2) == 0 || remainder(n, 3) == 0) return false;
  for (int d = 5; d <= 1001; d += 6) {
    if (d * d > n) break;
    if (remainder(n, d) == 0) return false;
    int next = d + 2;
    if (next * next <= n && remainder(n, next) == 0) return false;
  }
  return true;
}

float randomUnit(int n) {
  // Mix both halves of the 20-bit index with modular Feistel rounds. Each
  // round is a permutation; no bit operations or backend-specific float hash.
  int left = n / 1024;
  int right = remainder(n, 1024);
  for (int i = 0; i < 4; i++) {
    int t = right + 17 + 191 * i;
    int next = remainder(left + 73 * remainder(t * t, 1021), 1024);
    left = right;
    right = next;
  }
  return float(left * 1024 + right) / 1048576.0;
}

vec3 primeColor() {
  if (uColorScheme == 0.0) return vec3(1.0, 0.65, 0.29);
  if (uColorScheme == 1.0) return vec3(0.42, 0.94, 1.0);
  if (uColorScheme == 2.0) return vec3(0.88, 0.56, 1.0);
  return vec3(0.94);
}

void main() {
  float shortSide = uResolution.x < uResolution.y ? uResolution.x : uResolution.y;
  float pixelsPerCell = uZoom * shortSide / 203.0;
  vec2 p = (FlutterFragCoord().xy - 0.5 * uResolution) / pixelsPerCell
    + 203.0 * uPan;
  p.y = -p.y;
  vec2 cell = floor(p + 0.5);
  vec2 magnitude = abs(cell);
  float ring = magnitude.x > magnitude.y ? magnitude.x : magnitude.y;
  vec4 bg = uTransparentBg > 0.5 ? vec4(0.0) : vec4(0.018, 0.025, 0.048, 1.0);
  if (ring > 500.0) {
    fragColor = bg;
    return;
  }

  int n = int(uStartValue) + ulamIndex(int(cell.x), int(cell.y), int(ring)) - 1;
  bool lit = uPattern == 0.0 ? isPrime(n) : (n >= 2 && randomUnit(n) < 1.0 / log(float(n)));
  vec2 delta = abs(p - cell);
  float edge = delta.x > delta.y ? delta.x : delta.y;
  // A thin gap separates cells without breaking diagonal continuity at 1x.
  float coverage = 1.0 - smoothstep(0.33, 0.5, edge);
  float alpha = coverage * (lit ? 0.97 : 0.24);
  vec3 color = primeColor() * (lit ? 1.0 : 0.32);
  fragColor = vec4(color * alpha, alpha) + bg * (1.0 - alpha);
}
