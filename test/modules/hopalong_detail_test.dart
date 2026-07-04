import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/strange_attractors/hopalong_gpu.frag';

  test('Hopalong shader keeps strand detail for issue view', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float trap = 1e9;'));
    expect(shader, contains('trap = min(trap, abs(sin(0.55 * p.x) + cos(0.45 * p.y))'));
    expect(shader, contains('float strands = exp(-3.5 * trap);'));
  });

  test('Hopalong shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
