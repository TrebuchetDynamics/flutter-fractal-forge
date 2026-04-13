// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0634_lyapunov_aaabab/f0634_lyapunov_aaabab_module.dart';

void main() {
  test('F0634LyapunovAaabab instantiates', () {
    final m = F0634LyapunovAaabab();
    expect(m.id, 'f0634_lyapunov_aaabab');
    expect(m.shader, 'shaders/f0634_lyapunov_aaabab_gpu.frag');
  });

  test('F0634LyapunovAaabab presets are well-formed', () {
    final m = F0634LyapunovAaabab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0634LyapunovAaabab metadata is consistent', () {
    final m = F0634LyapunovAaabab();
    expect(m.metadata.id, m.id);
  });
}
