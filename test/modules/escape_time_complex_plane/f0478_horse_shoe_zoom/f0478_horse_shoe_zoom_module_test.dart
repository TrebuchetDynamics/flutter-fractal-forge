// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0478_horse_shoe_zoom/f0478_horse_shoe_zoom_module.dart';

void main() {
  test('F0478HorseShoeZoom instantiates', () {
    final m = F0478HorseShoeZoom();
    expect(m.id, 'f0478_horse_shoe_zoom');
    expect(m.shader, 'shaders/f0478_horse_shoe_zoom_gpu.frag');
  });

  test('F0478HorseShoeZoom presets are well-formed', () {
    final m = F0478HorseShoeZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0478HorseShoeZoom metadata is consistent', () {
    final m = F0478HorseShoeZoom();
    expect(m.metadata.id, m.id);
  });
}
