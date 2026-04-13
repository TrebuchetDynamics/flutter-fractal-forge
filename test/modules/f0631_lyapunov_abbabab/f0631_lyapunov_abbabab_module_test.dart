// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0631_lyapunov_abbabab/f0631_lyapunov_abbabab_module.dart';

void main() {
  test('F0631LyapunovAbbabab instantiates', () {
    final m = F0631LyapunovAbbabab();
    expect(m.id, 'f0631_lyapunov_abbabab');
    expect(m.shader, 'shaders/f0631_lyapunov_abbabab_gpu.frag');
  });

  test('F0631LyapunovAbbabab presets are well-formed', () {
    final m = F0631LyapunovAbbabab();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0631LyapunovAbbabab metadata is consistent', () {
    final m = F0631LyapunovAbbabab();
    expect(m.metadata.id, m.id);
  });
}
