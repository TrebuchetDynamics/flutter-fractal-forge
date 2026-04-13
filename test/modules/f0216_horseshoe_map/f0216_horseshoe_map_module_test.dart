// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0216_horseshoe_map/f0216_horseshoe_map_module.dart';

void main() {
  test('F0216HorseshoeMap instantiates', () {
    final m = F0216HorseshoeMap();
    expect(m.id, 'f0216_horseshoe_map');
    expect(m.shader, 'shaders/f0216_horseshoe_map_gpu.frag');
  });

  test('F0216HorseshoeMap presets are well-formed', () {
    final m = F0216HorseshoeMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0216HorseshoeMap metadata is consistent', () {
    final m = F0216HorseshoeMap();
    expect(m.metadata.id, m.id);
  });
}
