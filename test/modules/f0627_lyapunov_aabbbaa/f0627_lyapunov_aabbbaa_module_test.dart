// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0627_lyapunov_aabbbaa/f0627_lyapunov_aabbbaa_module.dart';

void main() {
  test('F0627LyapunovAabbbaa instantiates', () {
    final m = F0627LyapunovAabbbaa();
    expect(m.id, 'f0627_lyapunov_aabbbaa');
    expect(m.shader, 'shaders/f0627_lyapunov_aabbbaa_gpu.frag');
  });

  test('F0627LyapunovAabbbaa presets are well-formed', () {
    final m = F0627LyapunovAabbbaa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0627LyapunovAabbbaa metadata is consistent', () {
    final m = F0627LyapunovAabbbaa();
    expect(m.metadata.id, m.id);
  });
}
