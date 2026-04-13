// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0419_gumowski_mira_spirals/f0419_gumowski_mira_spirals_module.dart';

void main() {
  test('F0419GumowskiMiraSpirals instantiates', () {
    final m = F0419GumowskiMiraSpirals();
    expect(m.id, 'f0419_gumowski_mira_spirals');
    expect(m.shader, 'shaders/f0419_gumowski_mira_spirals_gpu.frag');
  });

  test('F0419GumowskiMiraSpirals presets are well-formed', () {
    final m = F0419GumowskiMiraSpirals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0419GumowskiMiraSpirals metadata is consistent', () {
    final m = F0419GumowskiMiraSpirals();
    expect(m.metadata.id, m.id);
  });
}
