// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0658_magnet_iv/f0658_magnet_iv_module.dart';

void main() {
  test('F0658MagnetIv instantiates', () {
    final m = F0658MagnetIv();
    expect(m.id, 'f0658_magnet_iv');
    expect(m.shader, 'shaders/f0658_magnet_iv_gpu.frag');
  });

  test('F0658MagnetIv presets are well-formed', () {
    final m = F0658MagnetIv();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0658MagnetIv metadata is consistent', () {
    final m = F0658MagnetIv();
    expect(m.metadata.id, m.id);
  });
}
