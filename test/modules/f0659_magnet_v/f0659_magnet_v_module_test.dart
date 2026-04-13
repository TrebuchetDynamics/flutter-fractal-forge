// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0659_magnet_v/f0659_magnet_v_module.dart';

void main() {
  test('F0659MagnetV instantiates', () {
    final m = F0659MagnetV();
    expect(m.id, 'f0659_magnet_v');
    expect(m.shader, 'shaders/f0659_magnet_v_gpu.frag');
  });

  test('F0659MagnetV presets are well-formed', () {
    final m = F0659MagnetV();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0659MagnetV metadata is consistent', () {
    final m = F0659MagnetV();
    expect(m.metadata.id, m.id);
  });
}
