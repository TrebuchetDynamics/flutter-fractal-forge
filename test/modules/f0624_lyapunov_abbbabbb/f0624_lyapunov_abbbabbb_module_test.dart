// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0624_lyapunov_abbbabbb/f0624_lyapunov_abbbabbb_module.dart';

void main() {
  test('F0624LyapunovAbbbabbb instantiates', () {
    final m = F0624LyapunovAbbbabbb();
    expect(m.id, 'f0624_lyapunov_abbbabbb');
    expect(m.shader, 'shaders/f0624_lyapunov_abbbabbb_gpu.frag');
  });

  test('F0624LyapunovAbbbabbb presets are well-formed', () {
    final m = F0624LyapunovAbbbabbb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0624LyapunovAbbbabbb metadata is consistent', () {
    final m = F0624LyapunovAbbbabbb();
    expect(m.metadata.id, m.id);
  });
}
