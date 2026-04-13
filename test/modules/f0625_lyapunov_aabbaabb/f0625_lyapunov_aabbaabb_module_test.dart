// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0625_lyapunov_aabbaabb/f0625_lyapunov_aabbaabb_module.dart';

void main() {
  test('F0625LyapunovAabbaabb instantiates', () {
    final m = F0625LyapunovAabbaabb();
    expect(m.id, 'f0625_lyapunov_aabbaabb');
    expect(m.shader, 'shaders/f0625_lyapunov_aabbaabb_gpu.frag');
  });

  test('F0625LyapunovAabbaabb presets are well-formed', () {
    final m = F0625LyapunovAabbaabb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0625LyapunovAabbaabb metadata is consistent', () {
    final m = F0625LyapunovAabbaabb();
    expect(m.metadata.id, m.id);
  });
}
