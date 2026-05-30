// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1020_brian_s_brain/f1020_brian_s_brain_module.dart';

void main() {
  test('F1020BrianSBrain instantiates', () {
    final m = F1020BrianSBrain();
    expect(m.id, 'f1020_brian_s_brain');
    expect(m.shader, 'shaders/f1020_brian_s_brain_gpu.frag');
  });

  test('F1020BrianSBrain presets are well-formed', () {
    final m = F1020BrianSBrain();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1020BrianSBrain metadata is consistent', () {
    final m = F1020BrianSBrain();
    expect(m.metadata.id, m.id);
  });
}
