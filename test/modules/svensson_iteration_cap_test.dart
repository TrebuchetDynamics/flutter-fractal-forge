import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/strange_attractors/svensson_gpu.frag';

  test('Svensson shader honors high-detail catalog iteration settings', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('const int MAX_ITERS = 500;'));
    expect(shader, contains('int target = int(clamp(uIterations, 1.0, float(MAX_ITERS)))'));
  });

  test('Svensson shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
