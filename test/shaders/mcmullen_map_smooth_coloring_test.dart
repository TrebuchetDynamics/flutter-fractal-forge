import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('McMullen map uses degree-correct smooth escape coloring', () {
    const shaderPath =
        'shaders/escape_time_family/geometry_and_ifs/mcmullen_map_gpu.frag';
    final source = File(shaderPath).readAsStringSync();

    expect(
      source,
      contains('float smoothVal = float(it) - log2(log2(mag2)) / log2(nf);'),
    );
    expect(
      source,
      contains('float baseT = fract(smoothVal / 64.0 + uTime * 0.0001);'),
    );
    expect(
      source,
      contains('float t = fract(smoothVal / 64.0 + uTime * 0.0001);'),
    );

    final insideBranch = source.indexOf('if (it >= target)');
    final smoothCalculation = source.indexOf('float smoothVal =');
    expect(insideBranch, greaterThanOrEqualTo(0));
    expect(smoothCalculation, greaterThan(insideBranch));
    expect(
        source.indexOf('return;', insideBranch), lessThan(smoothCalculation));
  });
}
