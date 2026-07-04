import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

void main() {
  const shaderAsset =
      'shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag';

  test('reported Lichtenberg Growth share view is visible at first frame',
      () async {
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);
    final bytes = await renderTestShaderFrame(
      program: program,
      shaderAsset: shaderAsset,
      width: 96,
      height: 96,
      uniforms: const [
        0.0, // uTime: first frame/share preview
        96.0,
        96.0,
        0.0, // uCenter.x
        0.0, // uCenter.y
        1.0, // uZoom
        35.0, // uIterations from report
        4.0, // uBailout
        0.0, // uColorScheme
        0.0, // uTransparentBg
        0.3, // uGrowthSpeed from report
        0.5, // uBranchAngle from report
        5.0, // uComplexity from report
      ],
    );

    expect(_brightPixelCount(bytes), greaterThan(80));
    expect(_lumaRange(bytes), greaterThan(30));
  }, timeout: const Timeout(Duration(seconds: 60)));
}

int _brightPixelCount(List<int> bytes) {
  var count = 0;
  for (var i = 0; i < bytes.length; i += 4) {
    final luma =
        ((bytes[i] * 299 + bytes[i + 1] * 587 + bytes[i + 2] * 114) / 1000)
            .round();
    if (luma > 32) count++;
  }
  return count;
}

int _lumaRange(List<int> bytes) {
  var minLuma = 255;
  var maxLuma = 0;
  for (var i = 0; i < bytes.length; i += 4) {
    final luma =
        ((bytes[i] * 299 + bytes[i + 1] * 587 + bytes[i + 2] * 114) / 1000)
            .round();
    if (luma < minLuma) minLuma = luma;
    if (luma > maxLuma) maxLuma = luma;
  }
  return maxLuma - minLuma;
}
