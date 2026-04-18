// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0853_christmas_tree_snowy/f0853_christmas_tree_snowy_module.dart';

void main() {
  test('F0853ChristmasTreeSnowy instantiates', () {
    final m = F0853ChristmasTreeSnowy();
    expect(m.id, 'f0853_christmas_tree_snowy');
    expect(m.shader, 'shaders/f0853_christmas_tree_snowy_gpu.frag');
  });

  test('F0853ChristmasTreeSnowy presets are well-formed', () {
    final m = F0853ChristmasTreeSnowy();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0853ChristmasTreeSnowy metadata is consistent', () {
    final m = F0853ChristmasTreeSnowy();
    expect(m.metadata.id, m.id);
  });
}
