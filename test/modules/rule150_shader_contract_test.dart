import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag';

  test('Rule 150 shader uses trinomial parity, not neighboring Rule 90 rows', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float rule150State(int gen, int cell)'));
    expect(shader, contains('return rule150State(gen, cell);'));
    expect(shader, isNot(contains('rule90State(gen, cell - 1) + rule90State(gen, cell)')));
  });
}
