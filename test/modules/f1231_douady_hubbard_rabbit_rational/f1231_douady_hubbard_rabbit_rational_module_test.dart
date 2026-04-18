// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1231_douady_hubbard_rabbit_rational/f1231_douady_hubbard_rabbit_rational_module.dart';

void main() {
  test('F1231DouadyHubbardRabbitRational instantiates', () {
    final m = F1231DouadyHubbardRabbitRational();
    expect(m.id, 'f1231_douady_hubbard_rabbit_rational');
    expect(m.shader, 'shaders/f1231_douady_hubbard_rabbit_rational_gpu.frag');
  });

  test('F1231DouadyHubbardRabbitRational presets are well-formed', () {
    final m = F1231DouadyHubbardRabbitRational();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1231DouadyHubbardRabbitRational metadata is consistent', () {
    final m = F1231DouadyHubbardRabbitRational();
    expect(m.metadata.id, m.id);
  });
}
