// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0605_lyapunov_ab/f0605_lyapunov_ab_module.dart';

void main() {
  test('F0605LyapunovAb instantiates', () {
    final m = F0605LyapunovAb();
    expect(m.id, 'f0605_lyapunov_ab');
    expect(m.shader, 'shaders/f0605_lyapunov_ab_gpu.frag');
  });

  test('F0605LyapunovAb presets are well-formed', () {
    final m = F0605LyapunovAb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0605LyapunovAb metadata is consistent', () {
    final m = F0605LyapunovAb();
    expect(m.metadata.id, m.id);
  });
}
