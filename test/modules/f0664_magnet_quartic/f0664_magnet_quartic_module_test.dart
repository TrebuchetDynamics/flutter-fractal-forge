// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0664_magnet_quartic/f0664_magnet_quartic_module.dart';

void main() {
  test('F0664MagnetQuartic instantiates', () {
    final m = F0664MagnetQuartic();
    expect(m.id, 'f0664_magnet_quartic');
    expect(m.shader, 'shaders/f0664_magnet_quartic_gpu.frag');
  });

  test('F0664MagnetQuartic presets are well-formed', () {
    final m = F0664MagnetQuartic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0664MagnetQuartic metadata is consistent', () {
    final m = F0664MagnetQuartic();
    expect(m.metadata.id, m.id);
  });
}
