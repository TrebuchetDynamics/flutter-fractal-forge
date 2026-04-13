// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0607_lyapunov_aabab/f0607_lyapunov_aabab_module.dart';

void main() {
  test('F0607LyapunovAabab instantiates', () {
    final m = F0607LyapunovAabab();
    expect(m.id, 'f0607_lyapunov_aabab');
    expect(m.shader, 'shaders/f0607_lyapunov_aabab_gpu.frag');
  });

  test('F0607LyapunovAabab presets are well-formed', () {
    final m = F0607LyapunovAabab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0607LyapunovAabab metadata is consistent', () {
    final m = F0607LyapunovAabab();
    expect(m.metadata.id, m.id);
  });
}
