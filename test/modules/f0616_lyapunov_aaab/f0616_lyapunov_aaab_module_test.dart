// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0616_lyapunov_aaab/f0616_lyapunov_aaab_module.dart';

void main() {
  test('F0616LyapunovAaab instantiates', () {
    final m = F0616LyapunovAaab();
    expect(m.id, 'f0616_lyapunov_aaab');
    expect(m.shader, 'shaders/f0616_lyapunov_aaab_gpu.frag');
  });

  test('F0616LyapunovAaab presets are well-formed', () {
    final m = F0616LyapunovAaab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0616LyapunovAaab metadata is consistent', () {
    final m = F0616LyapunovAaab();
    expect(m.metadata.id, m.id);
  });
}
