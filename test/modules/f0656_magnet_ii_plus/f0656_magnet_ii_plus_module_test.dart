// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0656_magnet_ii_plus/f0656_magnet_ii_plus_module.dart';

void main() {
  test('F0656MagnetIiPlus instantiates', () {
    final m = F0656MagnetIiPlus();
    expect(m.id, 'f0656_magnet_ii_plus');
    expect(m.shader, 'shaders/f0656_magnet_ii_plus_gpu.frag');
  });

  test('F0656MagnetIiPlus presets are well-formed', () {
    final m = F0656MagnetIiPlus();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0656MagnetIiPlus metadata is consistent', () {
    final m = F0656MagnetIiPlus();
    expect(m.metadata.id, m.id);
  });
}
