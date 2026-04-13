// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0661_magnet_star/f0661_magnet_star_module.dart';

void main() {
  test('F0661MagnetStar instantiates', () {
    final m = F0661MagnetStar();
    expect(m.id, 'f0661_magnet_star');
    expect(m.shader, 'shaders/f0661_magnet_star_gpu.frag');
  });

  test('F0661MagnetStar presets are well-formed', () {
    final m = F0661MagnetStar();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0661MagnetStar metadata is consistent', () {
    final m = F0661MagnetStar();
    expect(m.metadata.id, m.id);
  });
}
