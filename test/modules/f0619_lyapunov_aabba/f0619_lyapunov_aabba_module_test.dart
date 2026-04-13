// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0619_lyapunov_aabba/f0619_lyapunov_aabba_module.dart';

void main() {
  test('F0619LyapunovAabba instantiates', () {
    final m = F0619LyapunovAabba();
    expect(m.id, 'f0619_lyapunov_aabba');
    expect(m.shader, 'shaders/f0619_lyapunov_aabba_gpu.frag');
  });

  test('F0619LyapunovAabba presets are well-formed', () {
    final m = F0619LyapunovAabba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0619LyapunovAabba metadata is consistent', () {
    final m = F0619LyapunovAabba();
    expect(m.metadata.id, m.id);
  });
}
