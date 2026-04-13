// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0606_lyapunov_ba/f0606_lyapunov_ba_module.dart';

void main() {
  test('F0606LyapunovBa instantiates', () {
    final m = F0606LyapunovBa();
    expect(m.id, 'f0606_lyapunov_ba');
    expect(m.shader, 'shaders/f0606_lyapunov_ba_gpu.frag');
  });

  test('F0606LyapunovBa presets are well-formed', () {
    final m = F0606LyapunovBa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0606LyapunovBa metadata is consistent', () {
    final m = F0606LyapunovBa();
    expect(m.metadata.id, m.id);
  });
}
