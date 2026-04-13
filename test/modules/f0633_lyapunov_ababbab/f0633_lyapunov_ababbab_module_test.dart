// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0633_lyapunov_ababbab/f0633_lyapunov_ababbab_module.dart';

void main() {
  test('F0633LyapunovAbabbab instantiates', () {
    final m = F0633LyapunovAbabbab();
    expect(m.id, 'f0633_lyapunov_ababbab');
    expect(m.shader, 'shaders/f0633_lyapunov_ababbab_gpu.frag');
  });

  test('F0633LyapunovAbabbab presets are well-formed', () {
    final m = F0633LyapunovAbabbab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0633LyapunovAbabbab metadata is consistent', () {
    final m = F0633LyapunovAbabbab();
    expect(m.metadata.id, m.id);
  });
}
