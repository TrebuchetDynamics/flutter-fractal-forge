// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0399_icon_d7_star/f0399_icon_d7_star_module.dart';

void main() {
  test('F0399IconD7Star instantiates', () {
    final m = F0399IconD7Star();
    expect(m.id, 'f0399_icon_d7_star');
    expect(m.shader, 'shaders/f0399_icon_d7_star_gpu.frag');
  });

  test('F0399IconD7Star presets are well-formed', () {
    final m = F0399IconD7Star();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0399IconD7Star metadata is consistent', () {
    final m = F0399IconD7Star();
    expect(m.metadata.id, m.id);
  });
}
