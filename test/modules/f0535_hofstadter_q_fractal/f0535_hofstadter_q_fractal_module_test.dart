// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0535_hofstadter_q_fractal/f0535_hofstadter_q_fractal_module.dart';

void main() {
  test('F0535HofstadterQFractal instantiates', () {
    final m = F0535HofstadterQFractal();
    expect(m.id, 'f0535_hofstadter_q_fractal');
    expect(m.shader, 'shaders/f0535_hofstadter_q_fractal_gpu.frag');
  });

  test('F0535HofstadterQFractal presets are well-formed', () {
    final m = F0535HofstadterQFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0535HofstadterQFractal metadata is consistent', () {
    final m = F0535HofstadterQFractal();
    expect(m.metadata.id, m.id);
  });
}
