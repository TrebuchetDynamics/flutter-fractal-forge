// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0537_newton_cos/f0537_newton_cos_module.dart';

void main() {
  test('F0537NewtonCos instantiates', () {
    final m = F0537NewtonCos();
    expect(m.id, 'f0537_newton_cos');
    expect(m.shader, 'shaders/f0537_newton_cos_gpu.frag');
  });

  test('F0537NewtonCos presets are well-formed', () {
    final m = F0537NewtonCos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0537NewtonCos metadata is consistent', () {
    final m = F0537NewtonCos();
    expect(m.metadata.id, m.id);
  });
}
