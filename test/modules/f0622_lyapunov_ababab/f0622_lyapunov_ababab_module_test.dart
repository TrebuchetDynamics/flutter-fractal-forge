// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0622_lyapunov_ababab/f0622_lyapunov_ababab_module.dart';

void main() {
  test('F0622LyapunovAbabab instantiates', () {
    final m = F0622LyapunovAbabab();
    expect(m.id, 'f0622_lyapunov_ababab');
    expect(m.shader, 'shaders/f0622_lyapunov_ababab_gpu.frag');
  });

  test('F0622LyapunovAbabab presets are well-formed', () {
    final m = F0622LyapunovAbabab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0622LyapunovAbabab metadata is consistent', () {
    final m = F0622LyapunovAbabab();
    expect(m.metadata.id, m.id);
  });
}
