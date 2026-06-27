import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bouali shader uses a trajectory step large enough for default detail',
      () {
    final source =
        File('shaders/strange_attractors/bouali_gpu.frag').readAsStringSync();

    expect(source, contains('const float dt = 0.01;'));
  });
}
