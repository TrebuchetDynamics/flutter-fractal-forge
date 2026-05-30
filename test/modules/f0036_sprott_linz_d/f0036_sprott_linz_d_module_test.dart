// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0036_sprott_linz_d/f0036_sprott_linz_d_module.dart';

void main() {
  test('F0036SprottLinzD instantiates', () {
    final m = F0036SprottLinzD();
    expect(m.id, 'f0036_sprott_linz_d');
    expect(m.shader, 'shaders/f0036_sprott_linz_d_gpu.frag');
  });

  test('F0036SprottLinzD presets are well-formed', () {
    final m = F0036SprottLinzD();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0036SprottLinzD metadata is consistent', () {
    final m = F0036SprottLinzD();
    expect(m.metadata.id, m.id);
  });
}
