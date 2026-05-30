// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0416_gumowski_mira_storm/f0416_gumowski_mira_storm_module.dart';

void main() {
  test('F0416GumowskiMiraStorm instantiates', () {
    final m = F0416GumowskiMiraStorm();
    expect(m.id, 'f0416_gumowski_mira_storm');
    expect(m.shader, 'shaders/f0416_gumowski_mira_storm_gpu.frag');
  });

  test('F0416GumowskiMiraStorm presets are well-formed', () {
    final m = F0416GumowskiMiraStorm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0416GumowskiMiraStorm metadata is consistent', () {
    final m = F0416GumowskiMiraStorm();
    expect(m.metadata.id, m.id);
  });
}
