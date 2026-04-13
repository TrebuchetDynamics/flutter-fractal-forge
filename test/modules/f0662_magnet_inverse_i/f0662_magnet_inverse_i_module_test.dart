// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0662_magnet_inverse_i/f0662_magnet_inverse_i_module.dart';

void main() {
  test('F0662MagnetInverseI instantiates', () {
    final m = F0662MagnetInverseI();
    expect(m.id, 'f0662_magnet_inverse_i');
    expect(m.shader, 'shaders/f0662_magnet_inverse_i_gpu.frag');
  });

  test('F0662MagnetInverseI presets are well-formed', () {
    final m = F0662MagnetInverseI();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0662MagnetInverseI metadata is consistent', () {
    final m = F0662MagnetInverseI();
    expect(m.metadata.id, m.id);
  });
}
