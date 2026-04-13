// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0583_amazing_box_classic/f0583_amazing_box_classic_module.dart';

void main() {
  test('F0583AmazingBoxClassic instantiates', () {
    final m = F0583AmazingBoxClassic();
    expect(m.id, 'f0583_amazing_box_classic');
    expect(m.shader, 'shaders/f0583_amazing_box_classic_gpu.frag');
  });

  test('F0583AmazingBoxClassic presets are well-formed', () {
    final m = F0583AmazingBoxClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0583AmazingBoxClassic metadata is consistent', () {
    final m = F0583AmazingBoxClassic();
    expect(m.metadata.id, m.id);
  });
}
