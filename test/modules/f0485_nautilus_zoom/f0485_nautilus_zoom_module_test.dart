// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0485_nautilus_zoom/f0485_nautilus_zoom_module.dart';

void main() {
  test('F0485NautilusZoom instantiates', () {
    final m = F0485NautilusZoom();
    expect(m.id, 'f0485_nautilus_zoom');
    expect(m.shader, 'shaders/f0485_nautilus_zoom_gpu.frag');
  });

  test('F0485NautilusZoom presets are well-formed', () {
    final m = F0485NautilusZoom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0485NautilusZoom metadata is consistent', () {
    final m = F0485NautilusZoom();
    expect(m.metadata.id, m.id);
  });
}
