import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F0147 San Marco Julia uses the bundled shared Julia shader', () {
    final module = ModuleRegistry().byId('f0147_san_marco_julia');

    expect(
        module.shaderAsset, 'shaders/escape_time_family/core/julia_gpu.frag');
    expect(File(module.shaderAsset).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shaderAsset}'),
    );
  });
}
