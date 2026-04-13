// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0601_kleinian_3d_limit_apollonian/f0601_kleinian_3d_limit_apollonian_module.dart';

void main() {
  test('F0601Kleinian3dLimitApollonian instantiates', () {
    final m = F0601Kleinian3dLimitApollonian();
    expect(m.id, 'f0601_kleinian_3d_limit_apollonian');
    expect(m.shader, 'shaders/f0601_kleinian_3d_limit_apollonian_gpu.frag');
  });

  test('F0601Kleinian3dLimitApollonian presets are well-formed', () {
    final m = F0601Kleinian3dLimitApollonian();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0601Kleinian3dLimitApollonian metadata is consistent', () {
    final m = F0601Kleinian3dLimitApollonian();
    expect(m.metadata.id, m.id);
  });
}
