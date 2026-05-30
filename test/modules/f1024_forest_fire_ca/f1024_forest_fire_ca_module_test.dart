// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1024_forest_fire_ca/f1024_forest_fire_ca_module.dart';

void main() {
  test('F1024ForestFireCa instantiates', () {
    final m = F1024ForestFireCa();
    expect(m.id, 'f1024_forest_fire_ca');
    expect(m.shader, 'shaders/f1024_forest_fire_ca_gpu.frag');
  });

  test('F1024ForestFireCa presets are well-formed', () {
    final m = F1024ForestFireCa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1024ForestFireCa metadata is consistent', () {
    final m = F1024ForestFireCa();
    expect(m.metadata.id, m.id);
  });
}
