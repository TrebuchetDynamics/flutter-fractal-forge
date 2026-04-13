// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0628_lyapunov_abbbba/f0628_lyapunov_abbbba_module.dart';

void main() {
  test('F0628LyapunovAbbbba instantiates', () {
    final m = F0628LyapunovAbbbba();
    expect(m.id, 'f0628_lyapunov_abbbba');
    expect(m.shader, 'shaders/f0628_lyapunov_abbbba_gpu.frag');
  });

  test('F0628LyapunovAbbbba presets are well-formed', () {
    final m = F0628LyapunovAbbbba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0628LyapunovAbbbba metadata is consistent', () {
    final m = F0628LyapunovAbbbba();
    expect(m.metadata.id, m.id);
  });
}
