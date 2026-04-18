// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0808_tent_map_mu_1_5/f0808_tent_map_mu_1_5_module.dart';

void main() {
  test('F0808TentMapMu15 instantiates', () {
    final m = F0808TentMapMu15();
    expect(m.id, 'f0808_tent_map_mu_1_5');
    expect(m.shader, 'shaders/f0808_tent_map_mu_1_5_gpu.frag');
  });

  test('F0808TentMapMu15 presets are well-formed', () {
    final m = F0808TentMapMu15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0808TentMapMu15 metadata is consistent', () {
    final m = F0808TentMapMu15();
    expect(m.metadata.id, m.id);
  });
}
