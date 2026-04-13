// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0418_gumowski_mira_octopus/f0418_gumowski_mira_octopus_module.dart';

void main() {
  test('F0418GumowskiMiraOctopus instantiates', () {
    final m = F0418GumowskiMiraOctopus();
    expect(m.id, 'f0418_gumowski_mira_octopus');
    expect(m.shader, 'shaders/f0418_gumowski_mira_octopus_gpu.frag');
  });

  test('F0418GumowskiMiraOctopus presets are well-formed', () {
    final m = F0418GumowskiMiraOctopus();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0418GumowskiMiraOctopus metadata is consistent', () {
    final m = F0418GumowskiMiraOctopus();
    expect(m.metadata.id, m.id);
  });
}
