import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  const assets = [
    'shaders/3d_and_hypercomplex/raymarched_volumes/amazing_box_gpu.frag',
    'shaders/3d_and_hypercomplex/raymarched_volumes/bulbils_gpu.frag',
    'shaders/3d_and_hypercomplex/raymarched_volumes/tglad_formula_gpu.frag',
    'shaders/3d_and_hypercomplex/raymarched_volumes/dual_quaternion_julia_gpu.frag',
    'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_shape_inversion_gpu.frag',
    'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
  ];

  test('raymarched 3D shaders use shared pan as camera target', () {
    for (final asset in assets) {
      final shader = File(asset).readAsStringSync();

      expect(shader, contains('vec3 target = vec3(uMousePos, 0.0);'),
          reason: asset);
      expect(shader, contains('target + rot * vec3'), reason: asset);
      expect(shader, contains('normalize(rot * vec3(uv.x, uv.y, -1.5))'),
          reason: asset);
    }
  });

  test('raymarched 3D pan target shaders compile', () async {
    for (final asset in assets) {
      expect(await ui.FragmentProgram.fromAsset(asset), isNotNull,
          reason: asset);
    }
  }, timeout: const Timeout(Duration(seconds: 90)));
}
