// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0663_magnet_cubic/f0663_magnet_cubic_module.dart';

void main() {
  test('F0663MagnetCubic instantiates', () {
    final m = F0663MagnetCubic();
    expect(m.id, 'f0663_magnet_cubic');
    expect(m.shader, 'shaders/f0663_magnet_cubic_gpu.frag');
  });

  test('F0663MagnetCubic presets are well-formed', () {
    final m = F0663MagnetCubic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0663MagnetCubic metadata is consistent', () {
    final m = F0663MagnetCubic();
    expect(m.metadata.id, m.id);
  });
}
