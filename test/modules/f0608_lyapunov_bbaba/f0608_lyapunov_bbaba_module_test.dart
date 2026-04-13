// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0608_lyapunov_bbaba/f0608_lyapunov_bbaba_module.dart';

void main() {
  test('F0608LyapunovBbaba instantiates', () {
    final m = F0608LyapunovBbaba();
    expect(m.id, 'f0608_lyapunov_bbaba');
    expect(m.shader, 'shaders/f0608_lyapunov_bbaba_gpu.frag');
  });

  test('F0608LyapunovBbaba presets are well-formed', () {
    final m = F0608LyapunovBbaba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0608LyapunovBbaba metadata is consistent', () {
    final m = F0608LyapunovBbaba();
    expect(m.metadata.id, m.id);
  });
}
