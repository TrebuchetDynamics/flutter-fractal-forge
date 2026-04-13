// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0615_lyapunov_abba/f0615_lyapunov_abba_module.dart';

void main() {
  test('F0615LyapunovAbba instantiates', () {
    final m = F0615LyapunovAbba();
    expect(m.id, 'f0615_lyapunov_abba');
    expect(m.shader, 'shaders/f0615_lyapunov_abba_gpu.frag');
  });

  test('F0615LyapunovAbba presets are well-formed', () {
    final m = F0615LyapunovAbba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0615LyapunovAbba metadata is consistent', () {
    final m = F0615LyapunovAbba();
    expect(m.metadata.id, m.id);
  });
}
