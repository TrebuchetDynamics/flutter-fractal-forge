// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0638_lyapunov_aabaabb/f0638_lyapunov_aabaabb_module.dart';

void main() {
  test('F0638LyapunovAabaabb instantiates', () {
    final m = F0638LyapunovAabaabb();
    expect(m.id, 'f0638_lyapunov_aabaabb');
    expect(m.shader, 'shaders/f0638_lyapunov_aabaabb_gpu.frag');
  });

  test('F0638LyapunovAabaabb presets are well-formed', () {
    final m = F0638LyapunovAabaabb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0638LyapunovAabaabb metadata is consistent', () {
    final m = F0638LyapunovAabaabb();
    expect(m.metadata.id, m.id);
  });
}
