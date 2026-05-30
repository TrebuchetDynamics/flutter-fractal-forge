// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0463_double_scroll_zoom/f0463_double_scroll_zoom_module.dart';

void main() {
  test('F0463DoubleScrollZoom instantiates', () {
    final m = F0463DoubleScrollZoom();
    expect(m.id, 'f0463_double_scroll_zoom');
    expect(m.shader, 'shaders/f0463_double_scroll_zoom_gpu.frag');
  });

  test('F0463DoubleScrollZoom presets are well-formed', () {
    final m = F0463DoubleScrollZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0463DoubleScrollZoom metadata is consistent', () {
    final m = F0463DoubleScrollZoom();
    expect(m.metadata.id, m.id);
  });
}
