// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0466_baby_cardioid_zoom/f0466_baby_cardioid_zoom_module.dart';

void main() {
  test('F0466BabyCardioidZoom instantiates', () {
    final m = F0466BabyCardioidZoom();
    expect(m.id, 'f0466_baby_cardioid_zoom');
    expect(m.shader, 'shaders/f0466_baby_cardioid_zoom_gpu.frag');
  });

  test('F0466BabyCardioidZoom presets are well-formed', () {
    final m = F0466BabyCardioidZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0466BabyCardioidZoom metadata is consistent', () {
    final m = F0466BabyCardioidZoom();
    expect(m.metadata.id, m.id);
  });
}
