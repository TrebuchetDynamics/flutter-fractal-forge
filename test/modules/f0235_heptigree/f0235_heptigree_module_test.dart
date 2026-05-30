// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0235_heptigree/f0235_heptigree_module.dart';

void main() {
  test('F0235Heptigree instantiates', () {
    final m = F0235Heptigree();
    expect(m.id, 'f0235_heptigree');
    expect(m.shader, 'shaders/f0235_heptigree_gpu.frag');
  });

  test('F0235Heptigree presets are well-formed', () {
    final m = F0235Heptigree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0235Heptigree metadata is consistent', () {
    final m = F0235Heptigree();
    expect(m.metadata.id, m.id);
  });
}
