// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0068_nos_hoover/f0068_nos_hoover_module.dart';

void main() {
  test('F0068NosHoover instantiates', () {
    final m = F0068NosHoover();
    expect(m.id, 'f0068_nos_hoover');
    expect(m.shader, 'shaders/f0068_nos_hoover_gpu.frag');
  });

  test('F0068NosHoover presets are well-formed', () {
    final m = F0068NosHoover();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0068NosHoover metadata is consistent', () {
    final m = F0068NosHoover();
    expect(m.metadata.id, m.id);
  });
}
