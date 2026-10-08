import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('perturbation shader colors escaped pixels from final magnitude', () {
    const shaderPath =
        'shaders/escape_time_family/core/escape_time_perturb_gpu.frag';
    final source = File(shaderPath).readAsStringSync();

    final escapeMagnitude = RegExp(
      r'if\s*\(mag2\s*>\s*bailoutSq\)\s*\{\s*it\s*=\s*n;\s*finalMag2\s*=\s*mag2;\s*break;\s*\}',
    ).firstMatch(source);
    expect(
      escapeMagnitude,
      isNotNull,
      reason: '$shaderPath records the escaped magnitude before leaving loop',
    );

    final insideSetBranch = source.indexOf('if (it >= maxIter)');
    expect(insideSetBranch, greaterThan(escapeMagnitude!.end));
    final insideSetOutput = source.substring(insideSetBranch);
    expect(insideSetOutput, contains('vec4(0.0, 0.0, 0.0, 1.0)'));
    expect(insideSetOutput, contains('return;'));

    final escapedColoring = source.substring(insideSetBranch);
    final smoothValue = RegExp(
      r'float\s+smoothVal\s*=\s*float\(it\)\s*-\s*log2\(log2\(max\(1e-12,\s*finalMag2\)\)\)\s*\+\s*4\.0\s*;',
    ).firstMatch(escapedColoring);
    expect(
      smoothValue,
      isNotNull,
      reason: '$shaderPath derives smooth iteration from the final escaped '
          'magnitude after the inside-set branch',
    );

    final paletteCoordinate = RegExp(
      r'float\s+t\s*=\s*fract\(smoothVal\s*/\s*64\.0\s*\+\s*uTime\s*\*\s*uExtra1\)\s*;\s*fragColor\s*=\s*vec4\(linearToSRGB\(samplePalette\(t\)\),\s*1\.0\)',
    ).firstMatch(escapedColoring);
    expect(
      paletteCoordinate,
      isNotNull,
      reason:
          '$shaderPath uses the smooth value to form its palette coordinate',
    );
  });
}
