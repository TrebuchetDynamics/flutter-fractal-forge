// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0603_kleinian_schottky_3d/f0603_kleinian_schottky_3d_module.dart';

void main() {
  test('F0603KleinianSchottky3d instantiates', () {
    final m = F0603KleinianSchottky3d();
    expect(m.id, 'f0603_kleinian_schottky_3d');
    expect(m.shader, 'shaders/f0603_kleinian_schottky_3d_gpu.frag');
  });

  test('F0603KleinianSchottky3d presets are well-formed', () {
    final m = F0603KleinianSchottky3d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0603KleinianSchottky3d metadata is consistent', () {
    final m = F0603KleinianSchottky3d();
    expect(m.metadata.id, m.id);
  });
}
