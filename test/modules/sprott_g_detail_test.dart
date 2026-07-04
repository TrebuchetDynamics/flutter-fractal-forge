import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/strange_attractors/sprott_g_gpu.frag';

  test('Sprott G shader keeps a derivative-strand detail signal', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float trap = 1e9;'));
    expect(shader, contains('trap = min(trap, abs(-x + y) + 0.18 * abs(x * z - y));'));
    expect(shader, contains('float strands = exp(-4.5 * trap);'));
  });

  test('Sprott G shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
