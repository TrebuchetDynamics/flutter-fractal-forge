// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0620_lyapunov_baaba/f0620_lyapunov_baaba_module.dart';

void main() {
  test('F0620LyapunovBaaba instantiates', () {
    final m = F0620LyapunovBaaba();
    expect(m.id, 'f0620_lyapunov_baaba');
    expect(m.shader, 'shaders/f0620_lyapunov_baaba_gpu.frag');
  });

  test('F0620LyapunovBaaba presets are well-formed', () {
    final m = F0620LyapunovBaaba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0620LyapunovBaaba metadata is consistent', () {
    final m = F0620LyapunovBaaba();
    expect(m.metadata.id, m.id);
  });
}
