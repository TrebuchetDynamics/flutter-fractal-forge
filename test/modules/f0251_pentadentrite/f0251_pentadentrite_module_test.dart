// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0251_pentadentrite/f0251_pentadentrite_module.dart';

void main() {
  test('F0251Pentadentrite instantiates', () {
    final m = F0251Pentadentrite();
    expect(m.id, 'f0251_pentadentrite');
    expect(m.shader, 'shaders/f0251_pentadentrite_gpu.frag');
  });

  test('F0251Pentadentrite presets are well-formed', () {
    final m = F0251Pentadentrite();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0251Pentadentrite metadata is consistent', () {
    final m = F0251Pentadentrite();
    expect(m.metadata.id, m.id);
  });
}
