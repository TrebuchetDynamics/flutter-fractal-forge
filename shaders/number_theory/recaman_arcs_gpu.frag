#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution;
uniform vec2 uPan;
uniform float uZoom;
uniform float uTerms;
uniform float uLineWidth;
uniform float uLayout;
uniform float uColorScheme;
uniform float uTransparentBg;

out vec4 fragColor;

vec3 arcColor(float n) {
  // Fixed index mapping: increasing the count never recolors existing arcs.
  float t = fract(n / 64.0);
  if (uColorScheme == 0.0) return mix(vec3(0.96, 0.28, 0.16), vec3(1.0, 0.87, 0.43), t);
  if (uColorScheme == 1.0) return mix(vec3(0.24, 0.45, 0.99), vec3(0.46, 1.0, 0.87), t);
  if (uColorScheme == 3.0) return vec3(mix(0.55, 0.97, t));
  return 0.68 + 0.29 * cos(6.2831853 * (t + vec3(0.0, 0.33, 0.67)));
}

void main() {
  // OEIS A005132, a(0)..a(128). Element assignments work on both SkSL
  // and Impeller. Never run the recurrence or a membership scan per fragment.
  float T[129];
  T[0] = 0.0;
  T[1] = 1.0;
  T[2] = 3.0;
  T[3] = 6.0;
  T[4] = 2.0;
  T[5] = 7.0;
  T[6] = 13.0;
  T[7] = 20.0;
  T[8] = 12.0;
  T[9] = 21.0;
  T[10] = 11.0;
  T[11] = 22.0;
  T[12] = 10.0;
  T[13] = 23.0;
  T[14] = 9.0;
  T[15] = 24.0;
  T[16] = 8.0;
  T[17] = 25.0;
  T[18] = 43.0;
  T[19] = 62.0;
  T[20] = 42.0;
  T[21] = 63.0;
  T[22] = 41.0;
  T[23] = 18.0;
  T[24] = 42.0;
  T[25] = 17.0;
  T[26] = 43.0;
  T[27] = 16.0;
  T[28] = 44.0;
  T[29] = 15.0;
  T[30] = 45.0;
  T[31] = 14.0;
  T[32] = 46.0;
  T[33] = 79.0;
  T[34] = 113.0;
  T[35] = 78.0;
  T[36] = 114.0;
  T[37] = 77.0;
  T[38] = 39.0;
  T[39] = 78.0;
  T[40] = 38.0;
  T[41] = 79.0;
  T[42] = 37.0;
  T[43] = 80.0;
  T[44] = 36.0;
  T[45] = 81.0;
  T[46] = 35.0;
  T[47] = 82.0;
  T[48] = 34.0;
  T[49] = 83.0;
  T[50] = 33.0;
  T[51] = 84.0;
  T[52] = 32.0;
  T[53] = 85.0;
  T[54] = 31.0;
  T[55] = 86.0;
  T[56] = 30.0;
  T[57] = 87.0;
  T[58] = 29.0;
  T[59] = 88.0;
  T[60] = 28.0;
  T[61] = 89.0;
  T[62] = 27.0;
  T[63] = 90.0;
  T[64] = 26.0;
  T[65] = 91.0;
  T[66] = 157.0;
  T[67] = 224.0;
  T[68] = 156.0;
  T[69] = 225.0;
  T[70] = 155.0;
  T[71] = 226.0;
  T[72] = 154.0;
  T[73] = 227.0;
  T[74] = 153.0;
  T[75] = 228.0;
  T[76] = 152.0;
  T[77] = 75.0;
  T[78] = 153.0;
  T[79] = 74.0;
  T[80] = 154.0;
  T[81] = 73.0;
  T[82] = 155.0;
  T[83] = 72.0;
  T[84] = 156.0;
  T[85] = 71.0;
  T[86] = 157.0;
  T[87] = 70.0;
  T[88] = 158.0;
  T[89] = 69.0;
  T[90] = 159.0;
  T[91] = 68.0;
  T[92] = 160.0;
  T[93] = 67.0;
  T[94] = 161.0;
  T[95] = 66.0;
  T[96] = 162.0;
  T[97] = 65.0;
  T[98] = 163.0;
  T[99] = 64.0;
  T[100] = 164.0;
  T[101] = 265.0;
  T[102] = 367.0;
  T[103] = 264.0;
  T[104] = 368.0;
  T[105] = 263.0;
  T[106] = 369.0;
  T[107] = 262.0;
  T[108] = 370.0;
  T[109] = 261.0;
  T[110] = 151.0;
  T[111] = 40.0;
  T[112] = 152.0;
  T[113] = 265.0;
  T[114] = 379.0;
  T[115] = 494.0;
  T[116] = 378.0;
  T[117] = 495.0;
  T[118] = 377.0;
  T[119] = 258.0;
  T[120] = 138.0;
  T[121] = 259.0;
  T[122] = 137.0;
  T[123] = 260.0;
  T[124] = 136.0;
  T[125] = 261.0;
  T[126] = 135.0;
  T[127] = 262.0;
  T[128] = 134.0;

  // Number-plane origin is (57, 0) at viewport center with zero pan.
  // Fit a 128 by 76 box at 1x, leaving margins around [0,114] x [-32,32].
  // Camera pan uses the viewer convention (positive y is down on screen).
  float fit = min(uResolution.x / 128.0, uResolution.y / 76.0);
  float scale = max(1e-9, fit * uZoom);
  vec2 p = (FlutterFragCoord().xy - 0.5 * uResolution) / scale
    + uPan * min(uResolution.x, uResolution.y) / fit;
  p = vec2(p.x + 57.0, -p.y);

  float axis = 0.32 * (1.0 - smoothstep(0.0, 1.0, abs(p.y) * scale));
  vec4 bg = uTransparentBg > 0.5 ? vec4(0.0) : vec4(0.025, 0.035, 0.068, 1.0);
  vec4 result = vec4(vec3(0.54, 0.61, 0.76) * axis, axis) + bg * (1.0 - axis);
  float halfWidth = 0.5 * uLineWidth;
  float margin = (halfWidth + 0.5) / scale;
  for (int n = 1; n <= 128; n++) {
    if (float(n) > uTerms) break;
    float a = T[n - 1];
    float b = T[n];
    float radius = 0.5 * float(n); // |a(n) - a(n-1)| is exactly n.
    float dx = p.x - 0.5 * (a + b);
    float y = (uLayout > 0.5 || mod(float(n), 2.0) == 1.0) ? p.y : -p.y;
    if (abs(dx) > radius + margin || y > radius + margin || y < -margin) continue;

    // On the far side of the axis the nearest point is an endpoint.
    float distance = y >= 0.0 ? abs(length(vec2(dx, y)) - radius)
                              : length(vec2(abs(dx) - radius, y));
    float coverage = 1.0 - smoothstep(max(0.0, halfWidth - 0.5),
                                        halfWidth + 0.5, distance * scale);
    result = vec4(arcColor(float(n)) * coverage, coverage) + result * (1.0 - coverage);
  }
  fragColor = result;
}
