// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/lyapunov_stability/f0635_lyapunov_abbaba/f0635_lyapunov_abbaba_module.dart';

void main() {
  test('F0635LyapunovAbbaba instantiates', () {
    final m = F0635LyapunovAbbaba();
    expect(m.id, 'f0635_lyapunov_abbaba');
    expect(m.shader, 'shaders/f0635_lyapunov_abbaba_gpu.frag');
  });

  test('F0635LyapunovAbbaba presets are well-formed', () {
    final m = F0635LyapunovAbbaba();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0635LyapunovAbbaba metadata is consistent', () {
    final m = F0635LyapunovAbbaba();
    expect(m.metadata.id, m.id);
  });
}
