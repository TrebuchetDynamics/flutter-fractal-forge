// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0630_lyapunov_bbbaaa/f0630_lyapunov_bbbaaa_module.dart';

void main() {
  test('F0630LyapunovBbbaaa instantiates', () {
    final m = F0630LyapunovBbbaaa();
    expect(m.id, 'f0630_lyapunov_bbbaaa');
    expect(m.shader, 'shaders/f0630_lyapunov_bbbaaa_gpu.frag');
  });

  test('F0630LyapunovBbbaaa presets are well-formed', () {
    final m = F0630LyapunovBbbaaa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0630LyapunovBbbaaa metadata is consistent', () {
    final m = F0630LyapunovBbbaaa();
    expect(m.metadata.id, m.id);
  });
}
