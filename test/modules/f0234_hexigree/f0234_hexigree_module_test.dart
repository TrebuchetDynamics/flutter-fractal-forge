// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0234_hexigree/f0234_hexigree_module.dart';

void main() {
  test('F0234Hexigree instantiates', () {
    final m = F0234Hexigree();
    expect(m.id, 'f0234_hexigree');
    expect(m.shader, 'shaders/f0234_hexigree_gpu.frag');
  });

  test('F0234Hexigree presets are well-formed', () {
    final m = F0234Hexigree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0234Hexigree metadata is consistent', () {
    final m = F0234Hexigree();
    expect(m.metadata.id, m.id);
  });
}
