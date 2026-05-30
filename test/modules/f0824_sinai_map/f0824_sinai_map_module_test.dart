// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0824_sinai_map/f0824_sinai_map_module.dart';

void main() {
  test('F0824SinaiMap instantiates', () {
    final m = F0824SinaiMap();
    expect(m.id, 'f0824_sinai_map');
    expect(m.shader, 'shaders/f0824_sinai_map_gpu.frag');
  });

  test('F0824SinaiMap presets are well-formed', () {
    final m = F0824SinaiMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0824SinaiMap metadata is consistent', () {
    final m = F0824SinaiMap();
    expect(m.metadata.id, m.id);
  });
}
