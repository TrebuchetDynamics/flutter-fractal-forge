// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0034_sprott_linz_b/f0034_sprott_linz_b_module.dart';

void main() {
  test('F0034SprottLinzB instantiates', () {
    final m = F0034SprottLinzB();
    expect(m.id, 'f0034_sprott_linz_b');
    expect(m.shader, 'shaders/f0034_sprott_linz_b_gpu.frag');
  });

  test('F0034SprottLinzB presets are well-formed', () {
    final m = F0034SprottLinzB();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0034SprottLinzB metadata is consistent', () {
    final m = F0034SprottLinzB();
    expect(m.metadata.id, m.id);
  });
}
