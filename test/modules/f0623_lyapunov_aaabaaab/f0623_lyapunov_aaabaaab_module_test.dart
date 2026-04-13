// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0623_lyapunov_aaabaaab/f0623_lyapunov_aaabaaab_module.dart';

void main() {
  test('F0623LyapunovAaabaaab instantiates', () {
    final m = F0623LyapunovAaabaaab();
    expect(m.id, 'f0623_lyapunov_aaabaaab');
    expect(m.shader, 'shaders/f0623_lyapunov_aaabaaab_gpu.frag');
  });

  test('F0623LyapunovAaabaaab presets are well-formed', () {
    final m = F0623LyapunovAaabaaab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0623LyapunovAaabaaab metadata is consistent', () {
    final m = F0623LyapunovAaabaaab();
    expect(m.metadata.id, m.id);
  });
}
