// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0775_look_and_say_sequence_fractal/f0775_look_and_say_sequence_fractal_module.dart';

void main() {
  test('F0775LookAndSaySequenceFractal instantiates', () {
    final m = F0775LookAndSaySequenceFractal();
    expect(m.id, 'f0775_look_and_say_sequence_fractal');
    expect(m.shader, 'shaders/f0775_look_and_say_sequence_fractal_gpu.frag');
  });

  test('F0775LookAndSaySequenceFractal presets are well-formed', () {
    final m = F0775LookAndSaySequenceFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0775LookAndSaySequenceFractal metadata is consistent', () {
    final m = F0775LookAndSaySequenceFractal();
    expect(m.metadata.id, m.id);
  });
}
