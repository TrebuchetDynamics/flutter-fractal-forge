// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0626_lyapunov_abbabba/f0626_lyapunov_abbabba_module.dart';

void main() {
  test('F0626LyapunovAbbabba instantiates', () {
    final m = F0626LyapunovAbbabba();
    expect(m.id, 'f0626_lyapunov_abbabba');
    expect(m.shader, 'shaders/f0626_lyapunov_abbabba_gpu.frag');
  });

  test('F0626LyapunovAbbabba presets are well-formed', () {
    final m = F0626LyapunovAbbabba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0626LyapunovAbbabba metadata is consistent', () {
    final m = F0626LyapunovAbbabba();
    expect(m.metadata.id, m.id);
  });
}
