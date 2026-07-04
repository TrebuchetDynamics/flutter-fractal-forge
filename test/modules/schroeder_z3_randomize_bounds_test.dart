import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const shaderAsset = 'shaders/root_finding/schroeder_z3_gpu.frag';

  test('Schroeder z3 caps random iteration values to useful root-finding range',
      () {
    final module = ModuleRegistry().byId('schroeder_z3');
    final paramsById = {for (final param in module.parameters) param.id: param};

    expect(module.defaultPreset.params['iterations'], 80.0);
    expect(paramsById['iterations']!.max, 120.0);
  });

  test(
      'Schroeder z3 shader clamps random share iterations and avoids black fallback',
      () {
    final shader = File(shaderAsset).readAsStringSync();

    expect(shader, contains('const int MAX_ITERS = 120;'));
    expect(shader, contains('it = target > 0 ? target - 1 : 0;'));
    expect(shader, isNot(contains('vec4(0.0,0.0,0.0,1.0)')));
  });
}
