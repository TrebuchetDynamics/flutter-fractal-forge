// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0602_kleinian_3d_indra/f0602_kleinian_3d_indra_module.dart';

void main() {
  test('F0602Kleinian3dIndra instantiates', () {
    final m = F0602Kleinian3dIndra();
    expect(m.id, 'f0602_kleinian_3d_indra');
    expect(m.shader, 'shaders/f0602_kleinian_3d_indra_gpu.frag');
  });

  test('F0602Kleinian3dIndra presets are well-formed', () {
    final m = F0602Kleinian3dIndra();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0602Kleinian3dIndra metadata is consistent', () {
    final m = F0602Kleinian3dIndra();
    expect(m.metadata.id, m.id);
  });
}
