// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0629_lyapunov_aaabbb/f0629_lyapunov_aaabbb_module.dart';

void main() {
  test('F0629LyapunovAaabbb instantiates', () {
    final m = F0629LyapunovAaabbb();
    expect(m.id, 'f0629_lyapunov_aaabbb');
    expect(m.shader, 'shaders/f0629_lyapunov_aaabbb_gpu.frag');
  });

  test('F0629LyapunovAaabbb presets are well-formed', () {
    final m = F0629LyapunovAaabbb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0629LyapunovAaabbb metadata is consistent', () {
    final m = F0629LyapunovAaabbb();
    expect(m.metadata.id, m.id);
  });
}
