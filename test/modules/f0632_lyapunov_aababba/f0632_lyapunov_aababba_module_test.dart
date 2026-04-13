// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0632_lyapunov_aababba/f0632_lyapunov_aababba_module.dart';

void main() {
  test('F0632LyapunovAababba instantiates', () {
    final m = F0632LyapunovAababba();
    expect(m.id, 'f0632_lyapunov_aababba');
    expect(m.shader, 'shaders/f0632_lyapunov_aababba_gpu.frag');
  });

  test('F0632LyapunovAababba presets are well-formed', () {
    final m = F0632LyapunovAababba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0632LyapunovAababba metadata is consistent', () {
    final m = F0632LyapunovAababba();
    expect(m.metadata.id, m.id);
  });
}
