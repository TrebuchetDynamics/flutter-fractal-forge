// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0636_lyapunov_aabbabab/f0636_lyapunov_aabbabab_module.dart';

void main() {
  test('F0636LyapunovAabbabab instantiates', () {
    final m = F0636LyapunovAabbabab();
    expect(m.id, 'f0636_lyapunov_aabbabab');
    expect(m.shader, 'shaders/f0636_lyapunov_aabbabab_gpu.frag');
  });

  test('F0636LyapunovAabbabab presets are well-formed', () {
    final m = F0636LyapunovAabbabab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0636LyapunovAabbabab metadata is consistent', () {
    final m = F0636LyapunovAabbabab();
    expect(m.metadata.id, m.id);
  });
}
