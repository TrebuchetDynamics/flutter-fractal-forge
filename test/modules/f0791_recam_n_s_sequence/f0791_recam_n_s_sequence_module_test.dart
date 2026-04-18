// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0791_recam_n_s_sequence/f0791_recam_n_s_sequence_module.dart';

void main() {
  test('F0791RecamNSSequence instantiates', () {
    final m = F0791RecamNSSequence();
    expect(m.id, 'f0791_recam_n_s_sequence');
    expect(m.shader, 'shaders/f0791_recam_n_s_sequence_gpu.frag');
  });

  test('F0791RecamNSSequence presets are well-formed', () {
    final m = F0791RecamNSSequence();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0791RecamNSSequence metadata is consistent', () {
    final m = F0791RecamNSSequence();
    expect(m.metadata.id, m.id);
  });
}
