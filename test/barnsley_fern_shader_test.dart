import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barnsley_fern shader uses the classic forward IFS coefficients', () {
    final module = ModuleRegistry().modules.singleWhere(
          (module) => module.id == 'barnsley_fern',
        );
    final source = File(module.shaderAsset).readAsStringSync();

    const mainLeaflet =
        'q = vec2(0.85 * x + 0.04 * y, -0.04 * x + 0.85 * y + 1.6);';

    expect(
        module.shaderAsset, 'shaders/ifs_and_geometric/barnsley_fern_gpu.frag');
    expect(source, contains('vec2 q = vec2(0.0);'));
    expect(source, contains('r < 0.01'));
    expect(source, contains('r < 0.86'));
    expect(source, contains('r < 0.93'));
    expect(source, contains(mainLeaflet));
    expect(source, isNot(contains('inverse of')));
  });
}
