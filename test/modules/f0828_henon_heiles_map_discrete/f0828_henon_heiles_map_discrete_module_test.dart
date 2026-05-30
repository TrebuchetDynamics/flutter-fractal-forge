// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0828_henon_heiles_map_discrete/f0828_henon_heiles_map_discrete_module.dart';

void main() {
  test('F0828HenonHeilesMapDiscrete instantiates', () {
    final m = F0828HenonHeilesMapDiscrete();
    expect(m.id, 'f0828_henon_heiles_map_discrete');
    expect(m.shader, 'shaders/f0828_henon_heiles_map_discrete_gpu.frag');
  });

  test('F0828HenonHeilesMapDiscrete presets are well-formed', () {
    final m = F0828HenonHeilesMapDiscrete();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0828HenonHeilesMapDiscrete metadata is consistent', () {
    final m = F0828HenonHeilesMapDiscrete();
    expect(m.metadata.id, m.id);
  });
}
