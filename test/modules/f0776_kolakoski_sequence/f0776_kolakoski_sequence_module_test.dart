// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0776_kolakoski_sequence/f0776_kolakoski_sequence_module.dart';

void main() {
  test('F0776KolakoskiSequence instantiates', () {
    final m = F0776KolakoskiSequence();
    expect(m.id, 'f0776_kolakoski_sequence');
    expect(m.shader, 'shaders/f0776_kolakoski_sequence_gpu.frag');
  });

  test('F0776KolakoskiSequence presets are well-formed', () {
    final m = F0776KolakoskiSequence();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0776KolakoskiSequence metadata is consistent', () {
    final m = F0776KolakoskiSequence();
    expect(m.metadata.id, m.id);
  });
}
