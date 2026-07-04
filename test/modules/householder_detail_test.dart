import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/root_finding/householder_gpu.frag';

  test('Householder shader highlights basin boundaries for detail', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float boundary = 1.0 - smoothstep(0.0, 0.10'));
    expect(shader, contains('0.18 * boundary'));
    expect(shader, contains('0.72 + 0.45 * boundary'));
  });
}
