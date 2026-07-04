import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/strange_attractors/sprott_c_gpu.frag';

  test('Sprott C shader keeps an orbit-trap strand detail signal', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float trap = 1e9;'));
    expect(shader, contains('trap = min(trap, abs(z) + 0.25 * abs(x - y));'));
    expect(shader, contains('float strands = exp(-5.0 * trap);'));
  });

  test('Sprott C shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
