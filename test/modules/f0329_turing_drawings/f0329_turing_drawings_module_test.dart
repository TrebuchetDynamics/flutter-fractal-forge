// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0329_turing_drawings/f0329_turing_drawings_module.dart';

void main() {
  test('F0329TuringDrawings instantiates', () {
    final m = F0329TuringDrawings();
    expect(m.id, 'f0329_turing_drawings');
    expect(m.shader, 'shaders/f0329_turing_drawings_gpu.frag');
  });

  test('F0329TuringDrawings presets are well-formed', () {
    final m = F0329TuringDrawings();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0329TuringDrawings metadata is consistent', () {
    final m = F0329TuringDrawings();
    expect(m.metadata.id, m.id);
  });
}
