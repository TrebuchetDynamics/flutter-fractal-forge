// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1083_bogdanov_period_4/f1083_bogdanov_period_4_module.dart';

void main() {
  test('F1083BogdanovPeriod4 instantiates', () {
    final m = F1083BogdanovPeriod4();
    expect(m.id, 'f1083_bogdanov_period_4');
    expect(m.shader, 'shaders/f1083_bogdanov_period_4_gpu.frag');
  });

  test('F1083BogdanovPeriod4 presets are well-formed', () {
    final m = F1083BogdanovPeriod4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1083BogdanovPeriod4 metadata is consistent', () {
    final m = F1083BogdanovPeriod4();
    expect(m.metadata.id, m.id);
  });
}
