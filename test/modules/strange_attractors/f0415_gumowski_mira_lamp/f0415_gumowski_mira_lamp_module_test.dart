// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0415_gumowski_mira_lamp/f0415_gumowski_mira_lamp_module.dart';

void main() {
  test('F0415GumowskiMiraLamp instantiates', () {
    final m = F0415GumowskiMiraLamp();
    expect(m.id, 'f0415_gumowski_mira_lamp');
    expect(m.shader, 'shaders/f0415_gumowski_mira_lamp_gpu.frag');
  });

  test('F0415GumowskiMiraLamp presets are well-formed', () {
    final m = F0415GumowskiMiraLamp();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0415GumowskiMiraLamp metadata is consistent', () {
    final m = F0415GumowskiMiraLamp();
    expect(m.metadata.id, m.id);
  });
}
