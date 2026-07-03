import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('super_halley shader never returns missing-looking black', () {
    final module = ModuleRegistry().modules.singleWhere(
          (module) => module.id == 'super_halley',
        );

    expect(module.shaderAsset, 'shaders/root_finding/super_halley_gpu.frag');
    expect(File(module.shaderAsset).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('    - ${module.shaderAsset}'),
    );

    final source = File(module.shaderAsset).readAsStringSync();
    final capBranch = RegExp(
      r'if \(it >= target\) \{([\s\S]*?)\n  \}\n\n  vec2 r0',
    ).firstMatch(source)?.group(1);

    expect(capBranch, isNotNull);
    expect(capBranch, isNot(contains('fragColor')));
    expect(capBranch, isNot(contains('return;')));
  });
}
