// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0041_sprott_linz_i/f0041_sprott_linz_i_module.dart';

void main() {
  test('F0041SprottLinzI instantiates', () {
    final m = F0041SprottLinzI();
    expect(m.id, 'f0041_sprott_linz_i');
    expect(m.shader, 'shaders/f0041_sprott_linz_i_gpu.frag');
  });

  test('F0041SprottLinzI presets are well-formed', () {
    final m = F0041SprottLinzI();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0041SprottLinzI metadata is consistent', () {
    final m = F0041SprottLinzI();
    expect(m.metadata.id, m.id);
  });
}
