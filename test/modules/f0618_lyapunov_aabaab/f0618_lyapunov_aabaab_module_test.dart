// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0618_lyapunov_aabaab/f0618_lyapunov_aabaab_module.dart';

void main() {
  test('F0618LyapunovAabaab instantiates', () {
    final m = F0618LyapunovAabaab();
    expect(m.id, 'f0618_lyapunov_aabaab');
    expect(m.shader, 'shaders/f0618_lyapunov_aabaab_gpu.frag');
  });

  test('F0618LyapunovAabaab presets are well-formed', () {
    final m = F0618LyapunovAabaab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0618LyapunovAabaab metadata is consistent', () {
    final m = F0618LyapunovAabaab();
    expect(m.metadata.id, m.id);
  });
}
