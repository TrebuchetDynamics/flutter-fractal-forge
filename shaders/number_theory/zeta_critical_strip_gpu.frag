#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution;
uniform vec2 uPan;
uniform float uZoom;
uniform float uContours;
uniform float uGuides;

out vec4 fragColor;

const float PI = 3.141592653589793;
const float LN2 = 0.693147180559945;
const float LN_PI = 1.144729885849400;
const vec2 ONE = vec2(1.0, 0.0);

vec2 mul(vec2 a, vec2 b) {
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 divide(vec2 a, vec2 b) {
  return mul(a, vec2(b.x, -b.y)) / dot(b, b);
}

vec2 cis(float angle) {
  return vec2(cos(angle), sin(angle));
}

vec2 complexLog(vec2 z) {
  return vec2(log(length(z)), atan(z.y, z.x));
}

// (exp(z) - 1)/z near zero, including its limit at zero.
vec2 expSlope(vec2 z) {
  return ONE + mul(z, 0.5 * ONE + mul(z, ONE / 6.0 + z / 24.0));
}

vec2 borweinZeta(vec2 s) {
  // Borwein (2000), Algorithm 2, n = 50: w[k] = (d_k - d_n)/d_n.
  // Element assignments are required by Flutter's SkSL shader backend.
  float w[50];
  w[0] = -1.0;
  w[1] = -1.0;
  w[2] = -1.0;
  w[3] = -1.0;
  w[4] = -1.0;
  w[5] = -1.0;
  w[6] = -1.0;
  w[7] = -1.0;
  w[8] = -1.0;
  w[9] = -1.0;
  w[10] = -1.0;
  w[11] = -0.9999999999999992;
  w[12] = -0.9999999999999852;
  w[13] = -0.9999999999997845;
  w[14] = -0.9999999999973079;
  w[15] = -0.9999999999710746;
  w[16] = -0.999999999730425;
  w[17] = -0.9999999978052279;
  w[18] = -0.9999999842921771;
  w[19] = -0.9999999006381278;
  w[20] = -0.9999994418278422;
  w[21] = -0.999997203728888;
  w[22] = -0.9999874611374572;
  w[23] = -0.9999495073899707;
  w[24] = -0.999816871155403;
  w[25] = -0.9994002309671448;
  w[26] = -0.998221949891754;
  w[27] = -0.995218197716334;
  w[28] = -0.9883095677128683;
  w[29] = -0.9739656970704641;
  w[30] = -0.9470770175272452;
  w[31] = -0.9015752858835114;
  w[32] = -0.8321038920345966;
  w[33] = -0.7364957080523137;
  w[34] = -0.6180557189399335;
  w[35] = -0.48622686149311023;
  w[36] = -0.35470746145813403;
  w[37] = -0.2374550677949638;
  w[38] = -0.14439369429808976;
  w[39] = -0.07894393711347507;
  w[40] = -0.03838994199718532;
  w[41] = -0.016409456839304695;
  w[42] = -0.006081277066324643;
  w[43] = -0.0019217474833351398;
  w[44] = -0.0005069858540111238;
  w[45] = -0.00010852115541499642;
  w[46] = -1.8090800979659343e-05;
  w[47] = -2.2018711680970302e-06;
  w[48] = -1.7394196846341903e-07;
  w[49] = -6.690075710131501e-09;

  // 1 - 2^(1-s) vanishes at 1 + 2πik/log(2). For k != 0, eta
  // vanishes too: use divided differences of both instead of subtracting
  // nearly equal floats. At k = 0 there is a genuine pole.
  float period = 2.0 * PI / LN2;
  float height = period * floor(s.y / period + 0.5);
  vec2 delta = s - vec2(1.0, height);
  bool near = length(delta) < 0.025;
  bool removable = near && height != 0.0;
  vec2 sum = vec2(0.0);
  float sign = -1.0;
  for (int k = 0; k < 50; ++k) {
    float a = -log(float(k + 1));
    vec2 term = exp(a * s.x) * cis(a * s.y);
    if (removable) {
      term = (a * exp(a)) * mul(cis(a * height), expSlope(a * delta));
    }
    sum += (sign * w[k]) * term;
    sign = -sign;
  }
  vec2 denominator = ONE - exp(-LN2 * delta.x) * cis(-LN2 * delta.y);
  if (near) {
    denominator = LN2 * expSlope(-LN2 * delta);
    if (!removable) denominator = mul(delta, denominator);
  }
  return divide(sum, denominator);
}

// Lanczos log Γ(z), g=7, valid here since Re(1-s) > 1/2.
vec2 logGamma(vec2 z) {
  z -= ONE;
  vec2 a = 0.99999999999980993 * ONE;
  a += divide(676.5203681218851 * ONE, z + ONE);
  a -= divide(1259.1392167224028 * ONE, z + 2.0 * ONE);
  a += divide(771.32342877765313 * ONE, z + 3.0 * ONE);
  a -= divide(176.61502916214059 * ONE, z + 4.0 * ONE);
  a += divide(12.507343278686905 * ONE, z + 5.0 * ONE);
  a -= divide(0.13857109526572012 * ONE, z + 6.0 * ONE);
  a += divide(9.9843695780195716e-6 * ONE, z + 7.0 * ONE);
  a += divide(1.5056327351493116e-7 * ONE, z + 8.0 * ONE);
  vec2 t = z + 7.5 * ONE;
  return 0.918938533204673 * ONE + mul(z + 0.5 * ONE, complexLog(t)) - t + complexLog(a);
}

vec2 zeta(vec2 s) {
  if (s.x >= 0.5) return borweinZeta(s);
  if (all(equal(s, vec2(0.0)))) return -0.5 * ONE;
  vec2 reflected = ONE - s;
  // ζ(s) = 2^s π^(s−1) sin(πs/2) Γ(1−s) ζ(1−s).
  // Scale sin by exp(-|Im(πs/2)|) and put the removed factor into the
  // log-Gamma exponent so neither exponentially large factor overflows.
  vec2 angle = (0.5 * PI) * s;
  float decay = exp(-2.0 * abs(angle.y));
  float sinhScaled = 0.5 * (1.0 - decay);
  if (abs(angle.y) < 0.0125) {
    sinhScaled = abs(angle.y) * expSlope(vec2(-2.0 * abs(angle.y), 0.0)).x;
  }
  vec2 scaledSin = vec2(0.5 * sin(angle.x) * (1.0 + decay),
                        cos(angle.x) * sign(angle.y) * sinhScaled);
  vec2 power = LN2 * s - LN_PI * reflected + logGamma(reflected);
  power.x += abs(angle.y);
  return exp(power.x) * mul(cis(power.y), mul(scaledSin, borweinZeta(reflected)));
}

float line(float pixels, float width) {
  return 1.0 - smoothstep(0.0, width, abs(pixels));
}

void main() {
  // Same pan convention as the viewer: positive pan y samples farther down.
  float scale = min(uResolution.x, uResolution.y) / 29.0 * uZoom;
  vec2 p = (FlutterFragCoord().xy - 0.5 * uResolution) / scale + 29.0 * uPan;
  vec2 s = vec2(0.5 + p.x, 25.0 - p.y);
  float edge = max(abs(s.x) - 10.0, abs(s.y) - 50.0);
  vec3 color = vec3(0.09);
  if (edge <= 0.0) {
    if (all(equal(s, ONE))) {
      color = vec3(1.0); // The pole at s = 1 has no phase.
    } else {
      vec2 value = zeta(s);
      float hue = atan(value.y, value.x) / (2.0 * PI);
      vec3 rgb = clamp(abs(fract(hue + vec3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
      float brightness = 0.95;
      if (uContours > 0.5) {
        float logModulus = log2(max(length(value), 1e-12));
        brightness = mix(0.62, 0.99, smoothstep(0.0, 1.0, fract(logModulus)));
      }
      color = mix(vec3(0.15), vec3(1.0), rgb) * brightness;
    }
    if (uGuides > 0.5) {
      float strip = max(line(s.x * scale, 1.25), line((s.x - 1.0) * scale, 1.25));
      float critical = line((s.x - 0.5) * scale, 1.6);
      color = mix(color, vec3(1.0), max(0.27 * strip, 0.64 * critical));
    }
  }
  if (uGuides > 0.5) color = mix(color, vec3(0.58), 0.75 * line(edge * scale, 1.5));
  fragColor = vec4(color, 1.0);
}
