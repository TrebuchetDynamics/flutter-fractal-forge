// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1085_bogdanov_spiral/f1085_bogdanov_spiral_module.dart';

void main() {
  test('F1085BogdanovSpiral instantiates', () {
    final m = F1085BogdanovSpiral();
    expect(m.id, 'f1085_bogdanov_spiral');
    expect(m.shader, 'shaders/f1085_bogdanov_spiral_gpu.frag');
  });

  test('F1085BogdanovSpiral presets are well-formed', () {
    final m = F1085BogdanovSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1085BogdanovSpiral metadata is consistent', () {
    final m = F1085BogdanovSpiral();
    expect(m.metadata.id, m.id);
  });
}
