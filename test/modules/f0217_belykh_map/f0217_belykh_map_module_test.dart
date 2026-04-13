// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0217_belykh_map/f0217_belykh_map_module.dart';

void main() {
  test('F0217BelykhMap instantiates', () {
    final m = F0217BelykhMap();
    expect(m.id, 'f0217_belykh_map');
    expect(m.shader, 'shaders/f0217_belykh_map_gpu.frag');
  });

  test('F0217BelykhMap presets are well-formed', () {
    final m = F0217BelykhMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0217BelykhMap metadata is consistent', () {
    final m = F0217BelykhMap();
    expect(m.metadata.id, m.id);
  });
}
