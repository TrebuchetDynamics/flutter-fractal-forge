// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0657_magnet_iii/f0657_magnet_iii_module.dart';

void main() {
  test('F0657MagnetIii instantiates', () {
    final m = F0657MagnetIii();
    expect(m.id, 'f0657_magnet_iii');
    expect(m.shader, 'shaders/f0657_magnet_iii_gpu.frag');
  });

  test('F0657MagnetIii presets are well-formed', () {
    final m = F0657MagnetIii();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0657MagnetIii metadata is consistent', () {
    final m = F0657MagnetIii();
    expect(m.metadata.id, m.id);
  });
}
