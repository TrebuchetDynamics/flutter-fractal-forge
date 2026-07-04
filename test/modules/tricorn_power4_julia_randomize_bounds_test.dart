import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset =
      'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_power4_julia_gpu.frag';

  test('Tricorn power4 Julia caps randomized iteration values', () {
    final module = ModuleRegistry().byId('tricorn_power4_julia');
    final paramsById = {for (final param in module.parameters) param.id: param};

    expect(module.defaultPreset.params['iterations'], 160.0);
    expect(paramsById['iterations']!.max, 200.0);
  });

  test('Tricorn power4 Julia shader clamps imported high iteration shares', () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('const int MAX_ITERS = 200;'));
    expect(
        shader,
        contains(
            'int target = int(clamp(uIterations, 0.0, float(MAX_ITERS)))'));
  });

  test('Tricorn power4 Julia shader compiles', () async {
    expect(await ui.FragmentProgram.fromAsset(shaderAsset), isNotNull);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
