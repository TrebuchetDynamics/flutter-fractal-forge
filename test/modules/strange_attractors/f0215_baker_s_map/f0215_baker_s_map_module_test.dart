// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0215_baker_s_map/f0215_baker_s_map_module.dart';

void main() {
  test('F0215BakerSMap instantiates', () {
    final m = F0215BakerSMap();
    expect(m.id, 'f0215_baker_s_map');
    expect(m.shader, 'shaders/f0215_baker_s_map_gpu.frag');
  });

  test('F0215BakerSMap presets are well-formed', () {
    final m = F0215BakerSMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0215BakerSMap metadata is consistent', () {
    final m = F0215BakerSMap();
    expect(m.metadata.id, m.id);
  });
}
