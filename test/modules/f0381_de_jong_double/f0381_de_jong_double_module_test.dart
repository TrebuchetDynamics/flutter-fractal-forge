// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0381_de_jong_double/f0381_de_jong_double_module.dart';

void main() {
  test('F0381DeJongDouble instantiates', () {
    final m = F0381DeJongDouble();
    expect(m.id, 'f0381_de_jong_double');
    expect(m.shader, 'shaders/f0381_de_jong_double_gpu.frag');
  });

  test('F0381DeJongDouble presets are well-formed', () {
    final m = F0381DeJongDouble();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0381DeJongDouble metadata is consistent', () {
    final m = F0381DeJongDouble();
    expect(m.metadata.id, m.id);
  });
}
