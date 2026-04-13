// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0160_rabbit_classic/f0160_rabbit_classic_module.dart';

void main() {
  test('F0160RabbitClassic instantiates', () {
    final m = F0160RabbitClassic();
    expect(m.id, 'f0160_rabbit_classic');
    expect(m.shader, 'shaders/f0160_rabbit_classic_gpu.frag');
  });

  test('F0160RabbitClassic presets are well-formed', () {
    final m = F0160RabbitClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0160RabbitClassic metadata is consistent', () {
    final m = F0160RabbitClassic();
    expect(m.metadata.id, m.id);
  });
}
