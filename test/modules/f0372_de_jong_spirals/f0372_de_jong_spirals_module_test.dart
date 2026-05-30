// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0372_de_jong_spirals/f0372_de_jong_spirals_module.dart';

void main() {
  test('F0372DeJongSpirals instantiates', () {
    final m = F0372DeJongSpirals();
    expect(m.id, 'f0372_de_jong_spirals');
    expect(m.shader, 'shaders/f0372_de_jong_spirals_gpu.frag');
  });

  test('F0372DeJongSpirals presets are well-formed', () {
    final m = F0372DeJongSpirals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0372DeJongSpirals metadata is consistent', () {
    final m = F0372DeJongSpirals();
    expect(m.metadata.id, m.id);
  });
}
