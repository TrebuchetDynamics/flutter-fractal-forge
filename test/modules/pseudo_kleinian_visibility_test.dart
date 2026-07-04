import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/ifs_and_geometric/pseudo_kleinian_gpu.frag';

  test('Pseudo-Kleinian shader keeps visible fold linework', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float trap = 1e9;'));
    expect(shader, contains('trap = min(trap, length(abs(folded.xy) - vec2(0.72))'));
    expect(shader, contains('float linework = exp(-7.0 * max(0.0, trap));'));
  });

  test('Pseudo-Kleinian shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
