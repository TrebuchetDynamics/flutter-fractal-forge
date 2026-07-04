import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = 'shaders/ifs_and_geometric/raymarched_3d/kifs_snowflake_fold_gpu.frag';

  test('KIFS Snowflake keeps closest-hit glow for miss views', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('float closest = 1.0e9;'));
    expect(shader, contains('float lodFactor = clamp(uZoom, 0.8, 1.0);'));
    expect(shader, contains('float glow = exp(-10.0 * max(0.0, -hit.w));'));
  });

  test('KIFS Snowflake shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
