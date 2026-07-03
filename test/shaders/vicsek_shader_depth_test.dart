import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Vicsek shader supports reported high-iteration deep detail', () {
    final source =
        File('shaders/ifs_and_geometric/vicsek_gpu.frag').readAsStringSync();

    expect(source, contains('clamp(float(target / 20 + 1), 1.0, 20.0)'));
    expect(source, contains('for (int i = 0; i < 20; i++)'));
  });
}
