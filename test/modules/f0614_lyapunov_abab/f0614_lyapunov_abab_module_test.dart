// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0614_lyapunov_abab/f0614_lyapunov_abab_module.dart';

void main() {
  test('F0614LyapunovAbab instantiates', () {
    final m = F0614LyapunovAbab();
    expect(m.id, 'f0614_lyapunov_abab');
    expect(m.shader, 'shaders/f0614_lyapunov_abab_gpu.frag');
  });

  test('F0614LyapunovAbab presets are well-formed', () {
    final m = F0614LyapunovAbab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0614LyapunovAbab metadata is consistent', () {
    final m = F0614LyapunovAbab();
    expect(m.metadata.id, m.id);
  });
}
