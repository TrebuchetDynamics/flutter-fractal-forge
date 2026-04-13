// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0611_lyapunov_aab/f0611_lyapunov_aab_module.dart';

void main() {
  test('F0611LyapunovAab instantiates', () {
    final m = F0611LyapunovAab();
    expect(m.id, 'f0611_lyapunov_aab');
    expect(m.shader, 'shaders/f0611_lyapunov_aab_gpu.frag');
  });

  test('F0611LyapunovAab presets are well-formed', () {
    final m = F0611LyapunovAab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0611LyapunovAab metadata is consistent', () {
    final m = F0611LyapunovAab();
    expect(m.metadata.id, m.id);
  });
}
