// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0823_standard_map_k_6_0/f0823_standard_map_k_6_0_module.dart';

void main() {
  test('F0823StandardMapK60 instantiates', () {
    final m = F0823StandardMapK60();
    expect(m.id, 'f0823_standard_map_k_6_0');
    expect(m.shader, 'shaders/f0823_standard_map_k_6_0_gpu.frag');
  });

  test('F0823StandardMapK60 presets are well-formed', () {
    final m = F0823StandardMapK60();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0823StandardMapK60 metadata is consistent', () {
    final m = F0823StandardMapK60();
    expect(m.metadata.id, m.id);
  });
}
