// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0477_heart_zoom/f0477_heart_zoom_module.dart';

void main() {
  test('F0477HeartZoom instantiates', () {
    final m = F0477HeartZoom();
    expect(m.id, 'f0477_heart_zoom');
    expect(m.shader, 'shaders/f0477_heart_zoom_gpu.frag');
  });

  test('F0477HeartZoom presets are well-formed', () {
    final m = F0477HeartZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0477HeartZoom metadata is consistent', () {
    final m = F0477HeartZoom();
    expect(m.metadata.id, m.id);
  });
}
