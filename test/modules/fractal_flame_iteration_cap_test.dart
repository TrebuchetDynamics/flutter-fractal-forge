import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag';

  test('Fractal Flame shader honors catalog iteration settings', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('for (int i = 0; i < 200; i++)'));
    expect(shader, contains('const int MAX_ITERS = 200;'));
  });

  test('Fractal Flame shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
