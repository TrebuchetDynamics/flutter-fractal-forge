// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0356_clifford_swirl/f0356_clifford_swirl_module.dart';

void main() {
  test('F0356CliffordSwirl instantiates', () {
    final m = F0356CliffordSwirl();
    expect(m.id, 'f0356_clifford_swirl');
    expect(m.shader, 'shaders/f0356_clifford_swirl_gpu.frag');
  });

  test('F0356CliffordSwirl presets are well-formed', () {
    final m = F0356CliffordSwirl();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0356CliffordSwirl metadata is consistent', () {
    final m = F0356CliffordSwirl();
    expect(m.metadata.id, m.id);
  });
}
