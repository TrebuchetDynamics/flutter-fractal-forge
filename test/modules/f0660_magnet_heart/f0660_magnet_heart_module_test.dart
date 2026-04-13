// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0660_magnet_heart/f0660_magnet_heart_module.dart';

void main() {
  test('F0660MagnetHeart instantiates', () {
    final m = F0660MagnetHeart();
    expect(m.id, 'f0660_magnet_heart');
    expect(m.shader, 'shaders/f0660_magnet_heart_gpu.frag');
  });

  test('F0660MagnetHeart presets are well-formed', () {
    final m = F0660MagnetHeart();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0660MagnetHeart metadata is consistent', () {
    final m = F0660MagnetHeart();
    expect(m.metadata.id, m.id);
  });
}
