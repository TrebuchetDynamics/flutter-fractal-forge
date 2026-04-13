// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0406_icon_vines_d6/f0406_icon_vines_d6_module.dart';

void main() {
  test('F0406IconVinesD6 instantiates', () {
    final m = F0406IconVinesD6();
    expect(m.id, 'f0406_icon_vines_d6');
    expect(m.shader, 'shaders/f0406_icon_vines_d6_gpu.frag');
  });

  test('F0406IconVinesD6 presets are well-formed', () {
    final m = F0406IconVinesD6();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0406IconVinesD6 metadata is consistent', () {
    final m = F0406IconVinesD6();
    expect(m.metadata.id, m.id);
  });
}
