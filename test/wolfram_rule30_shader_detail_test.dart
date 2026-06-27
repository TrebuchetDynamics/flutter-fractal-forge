import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rule 30 shader wraps vertical panning into visible generations', () {
    final source = File(
      'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag',
    ).readAsStringSync();

    expect(source, contains('float row = fract(p.y + 0.5);'));
    expect(source, contains('int gen = int(floor(row * float(target)))'));
  });
}
