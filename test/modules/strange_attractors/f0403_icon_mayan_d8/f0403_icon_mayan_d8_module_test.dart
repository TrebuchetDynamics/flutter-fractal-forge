// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0403_icon_mayan_d8/f0403_icon_mayan_d8_module.dart';

void main() {
  test('F0403IconMayanD8 instantiates', () {
    final m = F0403IconMayanD8();
    expect(m.id, 'f0403_icon_mayan_d8');
    expect(m.shader, 'shaders/f0403_icon_mayan_d8_gpu.frag');
  });

  test('F0403IconMayanD8 presets are well-formed', () {
    final m = F0403IconMayanD8();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0403IconMayanD8 metadata is consistent', () {
    final m = F0403IconMayanD8();
    expect(m.metadata.id, m.id);
  });
}
