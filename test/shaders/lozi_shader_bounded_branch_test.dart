import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lozi shader colors bounded attractor orbits instead of black', () {
    final source =
        File('shaders/strange_attractors/lozi_gpu.frag').readAsStringSync();
    final boundedBranch = RegExp(
      r'if \(it >= target\) \{([\s\S]*?)\n  \}',
    ).firstMatch(source)?.group(1);

    expect(boundedBranch, isNotNull);
    expect(boundedBranch, contains('density'));
    expect(boundedBranch, contains('palette'));
    expect(boundedBranch, isNot(contains('vec4(0.0, 0.0, 0.0, 1.0)')));
  });
}
