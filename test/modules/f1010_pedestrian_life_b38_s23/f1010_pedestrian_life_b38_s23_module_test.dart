// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1010_pedestrian_life_b38_s23/f1010_pedestrian_life_b38_s23_module.dart';

void main() {
  test('F1010PedestrianLifeB38S23 instantiates', () {
    final m = F1010PedestrianLifeB38S23();
    expect(m.id, 'f1010_pedestrian_life_b38_s23');
    expect(m.shader, 'shaders/f1010_pedestrian_life_b38_s23_gpu.frag');
  });

  test('F1010PedestrianLifeB38S23 presets are well-formed', () {
    final m = F1010PedestrianLifeB38S23();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1010PedestrianLifeB38S23 metadata is consistent', () {
    final m = F1010PedestrianLifeB38S23();
    expect(m.metadata.id, m.id);
  });
}
