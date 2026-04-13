// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0655_magnet_i_plus/f0655_magnet_i_plus_module.dart';

void main() {
  test('F0655MagnetIPlus instantiates', () {
    final m = F0655MagnetIPlus();
    expect(m.id, 'f0655_magnet_i_plus');
    expect(m.shader, 'shaders/f0655_magnet_i_plus_gpu.frag');
  });

  test('F0655MagnetIPlus presets are well-formed', () {
    final m = F0655MagnetIPlus();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0655MagnetIPlus metadata is consistent', () {
    final m = F0655MagnetIPlus();
    expect(m.metadata.id, m.id);
  });
}
