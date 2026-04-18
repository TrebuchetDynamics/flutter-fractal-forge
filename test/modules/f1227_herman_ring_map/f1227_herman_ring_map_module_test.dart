// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1227_herman_ring_map/f1227_herman_ring_map_module.dart';

void main() {
  test('F1227HermanRingMap instantiates', () {
    final m = F1227HermanRingMap();
    expect(m.id, 'f1227_herman_ring_map');
    expect(m.shader, 'shaders/f1227_herman_ring_map_gpu.frag');
  });

  test('F1227HermanRingMap presets are well-formed', () {
    final m = F1227HermanRingMap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1227HermanRingMap metadata is consistent', () {
    final m = F1227HermanRingMap();
    expect(m.metadata.id, m.id);
  });
}
