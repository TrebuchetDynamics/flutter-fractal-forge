// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0665_magnet_phoenix_hybrid/f0665_magnet_phoenix_hybrid_module.dart';

void main() {
  test('F0665MagnetPhoenixHybrid instantiates', () {
    final m = F0665MagnetPhoenixHybrid();
    expect(m.id, 'f0665_magnet_phoenix_hybrid');
    expect(m.shader, 'shaders/f0665_magnet_phoenix_hybrid_gpu.frag');
  });

  test('F0665MagnetPhoenixHybrid presets are well-formed', () {
    final m = F0665MagnetPhoenixHybrid();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0665MagnetPhoenixHybrid metadata is consistent', () {
    final m = F0665MagnetPhoenixHybrid();
    expect(m.metadata.id, m.id);
  });
}
