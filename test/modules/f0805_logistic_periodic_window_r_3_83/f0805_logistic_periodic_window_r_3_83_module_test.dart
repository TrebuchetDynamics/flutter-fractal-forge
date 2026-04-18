// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0805_logistic_periodic_window_r_3_83/f0805_logistic_periodic_window_r_3_83_module.dart';

void main() {
  test('F0805LogisticPeriodicWindowR383 instantiates', () {
    final m = F0805LogisticPeriodicWindowR383();
    expect(m.id, 'f0805_logistic_periodic_window_r_3_83');
    expect(m.shader, 'shaders/f0805_logistic_periodic_window_r_3_83_gpu.frag');
  });

  test('F0805LogisticPeriodicWindowR383 presets are well-formed', () {
    final m = F0805LogisticPeriodicWindowR383();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0805LogisticPeriodicWindowR383 metadata is consistent', () {
    final m = F0805LogisticPeriodicWindowR383();
    expect(m.metadata.id, m.id);
  });
}
