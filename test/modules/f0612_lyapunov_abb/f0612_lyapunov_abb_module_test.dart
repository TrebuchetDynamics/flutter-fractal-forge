// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0612_lyapunov_abb/f0612_lyapunov_abb_module.dart';

void main() {
  test('F0612LyapunovAbb instantiates', () {
    final m = F0612LyapunovAbb();
    expect(m.id, 'f0612_lyapunov_abb');
    expect(m.shader, 'shaders/f0612_lyapunov_abb_gpu.frag');
  });

  test('F0612LyapunovAbb presets are well-formed', () {
    final m = F0612LyapunovAbb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0612LyapunovAbb metadata is consistent', () {
    final m = F0612LyapunovAbb();
    expect(m.metadata.id, m.id);
  });
}
