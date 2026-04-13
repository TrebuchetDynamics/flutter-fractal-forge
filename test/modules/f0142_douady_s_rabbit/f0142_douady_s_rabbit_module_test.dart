// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0142_douady_s_rabbit/f0142_douady_s_rabbit_module.dart';

void main() {
  test('F0142DouadySRabbit instantiates', () {
    final m = F0142DouadySRabbit();
    expect(m.id, 'f0142_douady_s_rabbit');
    expect(m.shader, 'shaders/f0142_douady_s_rabbit_gpu.frag');
  });

  test('F0142DouadySRabbit presets are well-formed', () {
    final m = F0142DouadySRabbit();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0142DouadySRabbit metadata is consistent', () {
    final m = F0142DouadySRabbit();
    expect(m.metadata.id, m.id);
  });
}
