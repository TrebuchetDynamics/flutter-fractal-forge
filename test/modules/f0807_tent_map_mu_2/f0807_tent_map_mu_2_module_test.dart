// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0807_tent_map_mu_2/f0807_tent_map_mu_2_module.dart';

void main() {
  test('F0807TentMapMu2 instantiates', () {
    final m = F0807TentMapMu2();
    expect(m.id, 'f0807_tent_map_mu_2');
    expect(m.shader, 'shaders/f0807_tent_map_mu_2_gpu.frag');
  });

  test('F0807TentMapMu2 presets are well-formed', () {
    final m = F0807TentMapMu2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0807TentMapMu2 metadata is consistent', () {
    final m = F0807TentMapMu2();
    expect(m.metadata.id, m.id);
  });
}
