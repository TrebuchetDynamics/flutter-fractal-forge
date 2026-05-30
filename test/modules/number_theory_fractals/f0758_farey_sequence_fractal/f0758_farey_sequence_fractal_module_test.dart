// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0758_farey_sequence_fractal/f0758_farey_sequence_fractal_module.dart';

void main() {
  test('F0758FareySequenceFractal instantiates', () {
    final m = F0758FareySequenceFractal();
    expect(m.id, 'f0758_farey_sequence_fractal');
    expect(m.shader, 'shaders/f0758_farey_sequence_fractal_gpu.frag');
  });

  test('F0758FareySequenceFractal presets are well-formed', () {
    final m = F0758FareySequenceFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0758FareySequenceFractal metadata is consistent', () {
    final m = F0758FareySequenceFractal();
    expect(m.metadata.id, m.id);
  });
}
