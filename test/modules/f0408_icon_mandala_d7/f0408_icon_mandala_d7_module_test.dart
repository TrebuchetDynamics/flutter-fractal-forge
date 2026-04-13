// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0408_icon_mandala_d7/f0408_icon_mandala_d7_module.dart';

void main() {
  test('F0408IconMandalaD7 instantiates', () {
    final m = F0408IconMandalaD7();
    expect(m.id, 'f0408_icon_mandala_d7');
    expect(m.shader, 'shaders/f0408_icon_mandala_d7_gpu.frag');
  });

  test('F0408IconMandalaD7 presets are well-formed', () {
    final m = F0408IconMandalaD7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0408IconMandalaD7 metadata is consistent', () {
    final m = F0408IconMandalaD7();
    expect(m.metadata.id, m.id);
  });
}
