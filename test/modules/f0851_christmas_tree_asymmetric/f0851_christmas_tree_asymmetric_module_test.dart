// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0851_christmas_tree_asymmetric/f0851_christmas_tree_asymmetric_module.dart';

void main() {
  test('F0851ChristmasTreeAsymmetric instantiates', () {
    final m = F0851ChristmasTreeAsymmetric();
    expect(m.id, 'f0851_christmas_tree_asymmetric');
    expect(m.shader, 'shaders/f0851_christmas_tree_asymmetric_gpu.frag');
  });

  test('F0851ChristmasTreeAsymmetric presets are well-formed', () {
    final m = F0851ChristmasTreeAsymmetric();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0851ChristmasTreeAsymmetric metadata is consistent', () {
    final m = F0851ChristmasTreeAsymmetric();
    expect(m.metadata.id, m.id);
  });
}
