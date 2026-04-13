// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0609_lyapunov_aaaaaabbbbbb/f0609_lyapunov_aaaaaabbbbbb_module.dart';

void main() {
  test('F0609LyapunovAaaaaabbbbbb instantiates', () {
    final m = F0609LyapunovAaaaaabbbbbb();
    expect(m.id, 'f0609_lyapunov_aaaaaabbbbbb');
    expect(m.shader, 'shaders/f0609_lyapunov_aaaaaabbbbbb_gpu.frag');
  });

  test('F0609LyapunovAaaaaabbbbbb presets are well-formed', () {
    final m = F0609LyapunovAaaaaabbbbbb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0609LyapunovAaaaaabbbbbb metadata is consistent', () {
    final m = F0609LyapunovAaaaaabbbbbb();
    expect(m.metadata.id, m.id);
  });
}
