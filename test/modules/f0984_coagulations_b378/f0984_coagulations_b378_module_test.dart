// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0984_coagulations_b378/f0984_coagulations_b378_module.dart';

void main() {
  test('F0984CoagulationsB378 instantiates', () {
    final m = F0984CoagulationsB378();
    expect(m.id, 'f0984_coagulations_b378');
    expect(m.shader, 'shaders/f0984_coagulations_b378_gpu.frag');
  });

  test('F0984CoagulationsB378 presets are well-formed', () {
    final m = F0984CoagulationsB378();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0984CoagulationsB378 metadata is consistent', () {
    final m = F0984CoagulationsB378();
    expect(m.metadata.id, m.id);
  });
}
