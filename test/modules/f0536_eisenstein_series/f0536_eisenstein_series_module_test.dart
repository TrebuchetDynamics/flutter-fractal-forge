// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0536_eisenstein_series/f0536_eisenstein_series_module.dart';

void main() {
  test('F0536EisensteinSeries instantiates', () {
    final m = F0536EisensteinSeries();
    expect(m.id, 'f0536_eisenstein_series');
    expect(m.shader, 'shaders/f0536_eisenstein_series_gpu.frag');
  });

  test('F0536EisensteinSeries presets are well-formed', () {
    final m = F0536EisensteinSeries();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0536EisensteinSeries metadata is consistent', () {
    final m = F0536EisensteinSeries();
    expect(m.metadata.id, m.id);
  });
}
