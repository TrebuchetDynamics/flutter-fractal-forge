import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('3D Koch shader has reachable folds', () {
    final module = ModuleRegistry().modules.singleWhere(
          (module) => module.id == 'f0598_3d_koch_snowflake',
        );
    final source = File(module.shaderAsset).readAsStringSync();

    expect(
      module.shaderAsset,
      'shaders/ifs_and_geometric/raymarched_3d/kifs_koch_fold_gpu.frag',
    );
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains(module.shaderAsset),
    );
    expect(source, contains('if (p.x < p.y) p.xy = p.yx;'));
    expect(source, contains('if (p.x < p.z) p.xz = p.zx;'));
    expect(source, contains('if (p.y < p.z) p.yz = p.zy;'));
    expect(source, isNot(contains('p.x + p.y < 0.0')));
    expect(source, contains('float minDist = 0.003 / max(uZoom, 0.1);'));
    expect(source, contains('color * (0.25 + diffuse * 0.75)'));
  });
}
