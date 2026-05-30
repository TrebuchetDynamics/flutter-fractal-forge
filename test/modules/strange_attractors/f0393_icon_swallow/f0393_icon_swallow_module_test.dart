// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0393_icon_swallow/f0393_icon_swallow_module.dart';

void main() {
  test('F0393IconSwallow instantiates', () {
    final m = F0393IconSwallow();
    expect(m.id, 'f0393_icon_swallow');
    expect(m.shader, 'shaders/f0393_icon_swallow_gpu.frag');
  });

  test('F0393IconSwallow presets are well-formed', () {
    final m = F0393IconSwallow();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0393IconSwallow metadata is consistent', () {
    final m = F0393IconSwallow();
    expect(m.metadata.id, m.id);
  });
}
