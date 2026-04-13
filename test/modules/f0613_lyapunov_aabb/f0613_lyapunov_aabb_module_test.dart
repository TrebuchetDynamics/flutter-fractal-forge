// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0613_lyapunov_aabb/f0613_lyapunov_aabb_module.dart';

void main() {
  test('F0613LyapunovAabb instantiates', () {
    final m = F0613LyapunovAabb();
    expect(m.id, 'f0613_lyapunov_aabb');
    expect(m.shader, 'shaders/f0613_lyapunov_aabb_gpu.frag');
  });

  test('F0613LyapunovAabb presets are well-formed', () {
    final m = F0613LyapunovAabb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0613LyapunovAabb metadata is consistent', () {
    final m = F0613LyapunovAabb();
    expect(m.metadata.id, m.id);
  });
}
