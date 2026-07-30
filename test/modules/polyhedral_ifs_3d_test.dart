import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset =
      'shaders/ifs_and_geometric/raymarched_3d/polyhedral_ifs_3d_gpu.frag';

  test('polyhedral modules map to distinct fixed transform systems', () {
    final registry = ModuleRegistry();
    final vicsek = registry.byId('vicsek_3d');
    final jerusalem = registry.byId('jerusalem_cube_3d');
    final octahedron = registry.byId('sierpinski_octahedron_3d');
    final cantorDust = registry.byId('cantor_dust_3d');

    for (final module in [vicsek, jerusalem, octahedron, cantorDust]) {
      expect(module.dimension, FractalDimension.threeD);
      expect(module.shaderAsset, asset);
      expect(module.parameters.any((parameter) => parameter.id == 'power'),
          isFalse);
    }
    expect(vicsek.defaultPreset.params['fractalType'] ?? 0, 0);
    expect(jerusalem.defaultPreset.params['fractalType'], 1);
    expect(octahedron.defaultPreset.params['fractalType'], 2);
    expect(cantorDust.defaultPreset.params['fractalType'], 3);
  });

  test('polyhedral shader locks researched map counts and scales', () {
    final shader = File(asset).readAsStringSync();

    expect(shader, contains('child < 7'));
    expect(shader, contains('childScale = 0.33333333333'));
    expect(shader, contains('cornerScale = 0.41421356237'));
    expect(shader, contains('edgeScale = 0.17157287525'));
    expect(shader, contains('child < 8'));
    expect(shader, contains('child < 12'));
    expect(shader, contains('child < 6'));
    expect(shader, contains('childScale = 0.5'));
    expect(shader, contains('float cantorDustDistance(vec3 point, int depth)'));
    expect(shader, contains('const float cantorScale = 0.33333333333'));
    expect(shader, contains('const float cantorOffset = 0.66666666667'));
  });

  test('polyhedral shader compiles as a Flutter runtime effect', () async {
    expect(await ui.FragmentProgram.fromAsset(asset), isNotNull);
  });
}
