// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0621_lyapunov_aabbab/f0621_lyapunov_aabbab_module.dart';

void main() {
  test('F0621LyapunovAabbab instantiates', () {
    final m = F0621LyapunovAabbab();
    expect(m.id, 'f0621_lyapunov_aabbab');
    expect(m.shader, 'shaders/f0621_lyapunov_aabbab_gpu.frag');
  });

  test('F0621LyapunovAabbab presets are well-formed', () {
    final m = F0621LyapunovAabbab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0621LyapunovAabbab metadata is consistent', () {
    final m = F0621LyapunovAabbab();
    expect(m.metadata.id, m.id);
  });
}
