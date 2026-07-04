import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag';

  test('Rule 90 shared shader keeps per-cell detail at 256 rows', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float cellCoord = (p.x + 0.5) * float(target);'));
    expect(shader, contains('float pixelDetail = 1.0 - smoothstep(0.42, 0.50, cellEdge);'));
    expect(shader, contains('rule90State(gen, cell)'));
  });

  test('Wolfram CA shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
