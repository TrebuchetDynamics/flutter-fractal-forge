// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0584_amazing_box_compact/f0584_amazing_box_compact_module.dart';

void main() {
  test('F0584AmazingBoxCompact instantiates', () {
    final m = F0584AmazingBoxCompact();
    expect(m.id, 'f0584_amazing_box_compact');
    expect(m.shader, 'shaders/f0584_amazing_box_compact_gpu.frag');
  });

  test('F0584AmazingBoxCompact presets are well-formed', () {
    final m = F0584AmazingBoxCompact();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0584AmazingBoxCompact metadata is consistent', () {
    final m = F0584AmazingBoxCompact();
    expect(m.metadata.id, m.id);
  });
}
