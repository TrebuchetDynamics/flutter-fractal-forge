import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/strange_attractors/dadras_gpu.frag';

  test('Dadras shader keeps a derivative-strand detail signal', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float trap = 1e9;'));
    expect(shader, contains('trap = min(trap, abs(d * x * y - e * z) + 0.12 * abs(y - a * x));'));
    expect(shader, contains('float strands = exp(-3.0 * trap);'));
  });

  test('Dadras shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
