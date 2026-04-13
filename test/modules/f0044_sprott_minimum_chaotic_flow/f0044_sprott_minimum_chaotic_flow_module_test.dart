// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0044_sprott_minimum_chaotic_flow/f0044_sprott_minimum_chaotic_flow_module.dart';

void main() {
  test('F0044SprottMinimumChaoticFlow instantiates', () {
    final m = F0044SprottMinimumChaoticFlow();
    expect(m.id, 'f0044_sprott_minimum_chaotic_flow');
    expect(m.shader, 'shaders/f0044_sprott_minimum_chaotic_flow_gpu.frag');
  });

  test('F0044SprottMinimumChaoticFlow presets are well-formed', () {
    final m = F0044SprottMinimumChaoticFlow();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0044SprottMinimumChaoticFlow metadata is consistent', () {
    final m = F0044SprottMinimumChaoticFlow();
    expect(m.metadata.id, m.id);
  });
}
