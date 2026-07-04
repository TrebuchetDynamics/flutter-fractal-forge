import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/render_test_shader.dart';

void main() {
  const shaderAsset =
      'shaders/escape_time_family/families/buddhabrot/buddhabrot_full_gpu.frag';

  test('Buddhabrot Full uses shared deterministic orbit seeds', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('vec2 buddhabrotSeed(float index)'));
    expect(shader, contains('vec2 c = buddhabrotSeed(float(s));'));
    expect(shader, isNot(contains('fragCoord * 0.01')));
    expect(shader, contains('no density should be black'));
  });

  test('Buddhabrot Full exposes sample controls for its extra uniforms', () {
    final module =
        escapeTimeCatalog.firstWhere((m) => m.id == 'buddhabrot_full');

    expect(module.extraParams.map((p) => p.id),
        containsAll(['samples', 'minIter']));
    expect(module.defaultIterations, 160);
  });

  test('reported Buddhabrot Full view renders histogram-like detail', () async {
    final program = await ui.FragmentProgram.fromAsset(shaderAsset);
    final bytes = await renderTestShaderFrame(
      program: program,
      shaderAsset: shaderAsset,
      width: 64,
      height: 64,
      uniforms: const [
        0.0, // uTime
        64.0, // uResolution.x
        64.0, // uResolution.y
        0.0, // uCenter.x from report
        0.0, // uCenter.y from report
        1.0, // uZoom from report
        158.0, // uIterations from report
        4.0, // uBailout from report
        0.0, // uColorScheme from report
        0.0, // uTransparentBg
        18.0, // uSamples default
        10.0, // uMinIter default
      ],
    );

    expect(_uniqueSampledColors(bytes), greaterThan(12));
    expect(_lumaRange(bytes), greaterThan(25));
    expect(_brightPixelCount(bytes), greaterThan(20));
  }, timeout: const Timeout(Duration(seconds: 60)));
}

int _uniqueSampledColors(List<int> bytes) {
  final colors = <int>{};
  for (var i = 0; i < bytes.length; i += 16) {
    colors.add((bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]);
  }
  return colors.length;
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
