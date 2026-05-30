// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0482_valley_of_the_double_spirals/f0482_valley_of_the_double_spirals_module.dart';

void main() {
  test('F0482ValleyOfTheDoubleSpirals instantiates', () {
    final m = F0482ValleyOfTheDoubleSpirals();
    expect(m.id, 'f0482_valley_of_the_double_spirals');
    expect(m.shader, 'shaders/f0482_valley_of_the_double_spirals_gpu.frag');
  });

  test('F0482ValleyOfTheDoubleSpirals presets are well-formed', () {
    final m = F0482ValleyOfTheDoubleSpirals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0482ValleyOfTheDoubleSpirals metadata is consistent', () {
    final m = F0482ValleyOfTheDoubleSpirals();
    expect(m.metadata.id, m.id);
  });
}
