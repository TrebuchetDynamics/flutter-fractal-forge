// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0617_lyapunov_abbb/f0617_lyapunov_abbb_module.dart';

void main() {
  test('F0617LyapunovAbbb instantiates', () {
    final m = F0617LyapunovAbbb();
    expect(m.id, 'f0617_lyapunov_abbb');
    expect(m.shader, 'shaders/f0617_lyapunov_abbb_gpu.frag');
  });

  test('F0617LyapunovAbbb presets are well-formed', () {
    final m = F0617LyapunovAbbb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0617LyapunovAbbb metadata is consistent', () {
    final m = F0617LyapunovAbbb();
    expect(m.metadata.id, m.id);
  });
}
