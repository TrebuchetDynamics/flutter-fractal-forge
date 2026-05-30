// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0794_goldbach_partitions_fractal/f0794_goldbach_partitions_fractal_module.dart';

void main() {
  test('F0794GoldbachPartitionsFractal instantiates', () {
    final m = F0794GoldbachPartitionsFractal();
    expect(m.id, 'f0794_goldbach_partitions_fractal');
    expect(m.shader, 'shaders/f0794_goldbach_partitions_fractal_gpu.frag');
  });

  test('F0794GoldbachPartitionsFractal presets are well-formed', () {
    final m = F0794GoldbachPartitionsFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0794GoldbachPartitionsFractal metadata is consistent', () {
    final m = F0794GoldbachPartitionsFractal();
    expect(m.metadata.id, m.id);
  });
}
