// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0159_rabbit_baby/f0159_rabbit_baby_module.dart';

void main() {
  test('F0159RabbitBaby instantiates', () {
    final m = F0159RabbitBaby();
    expect(m.id, 'f0159_rabbit_baby');
    expect(m.shader, 'shaders/f0159_rabbit_baby_gpu.frag');
  });

  test('F0159RabbitBaby presets are well-formed', () {
    final m = F0159RabbitBaby();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0159RabbitBaby metadata is consistent', () {
    final m = F0159RabbitBaby();
    expect(m.metadata.id, m.id);
  });
}
