// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0812_cusp_map/f0812_cusp_map_module.dart';

void main() {
  test('F0812CuspMap instantiates', () {
    final m = F0812CuspMap();
    expect(m.id, 'f0812_cusp_map');
    expect(m.shader, 'shaders/f0812_cusp_map_gpu.frag');
  });

  test('F0812CuspMap presets are well-formed', () {
    final m = F0812CuspMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0812CuspMap metadata is consistent', () {
    final m = F0812CuspMap();
    expect(m.metadata.id, m.id);
  });
}
