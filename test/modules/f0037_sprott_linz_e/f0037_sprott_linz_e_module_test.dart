// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0037_sprott_linz_e/f0037_sprott_linz_e_module.dart';

void main() {
  test('F0037SprottLinzE instantiates', () {
    final m = F0037SprottLinzE();
    expect(m.id, 'f0037_sprott_linz_e');
    expect(m.shader, 'shaders/f0037_sprott_linz_e_gpu.frag');
  });

  test('F0037SprottLinzE presets are well-formed', () {
    final m = F0037SprottLinzE();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0037SprottLinzE metadata is consistent', () {
    final m = F0037SprottLinzE();
    expect(m.metadata.id, m.id);
  });
}
