// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0423_gumowski_mira_coral_reef/f0423_gumowski_mira_coral_reef_module.dart';

void main() {
  test('F0423GumowskiMiraCoralReef instantiates', () {
    final m = F0423GumowskiMiraCoralReef();
    expect(m.id, 'f0423_gumowski_mira_coral_reef');
    expect(m.shader, 'shaders/f0423_gumowski_mira_coral_reef_gpu.frag');
  });

  test('F0423GumowskiMiraCoralReef presets are well-formed', () {
    final m = F0423GumowskiMiraCoralReef();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0423GumowskiMiraCoralReef metadata is consistent', () {
    final m = F0423GumowskiMiraCoralReef();
    expect(m.metadata.id, m.id);
  });
}
