// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0826_baker_s_map/f0826_baker_s_map_module.dart';

void main() {
  test('F0826BakerSMap instantiates', () {
    final m = F0826BakerSMap();
    expect(m.id, 'f0826_baker_s_map');
    expect(m.shader, 'shaders/f0826_baker_s_map_gpu.frag');
  });

  test('F0826BakerSMap presets are well-formed', () {
    final m = F0826BakerSMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0826BakerSMap metadata is consistent', () {
    final m = F0826BakerSMap();
    expect(m.metadata.id, m.id);
  });
}
