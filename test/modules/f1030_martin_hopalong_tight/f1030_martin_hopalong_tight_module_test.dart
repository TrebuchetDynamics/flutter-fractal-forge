// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1030_martin_hopalong_tight/f1030_martin_hopalong_tight_module.dart';

void main() {
  test('F1030MartinHopalongTight instantiates', () {
    final m = F1030MartinHopalongTight();
    expect(m.id, 'f1030_martin_hopalong_tight');
    expect(m.shader, 'shaders/f1030_martin_hopalong_tight_gpu.frag');
  });

  test('F1030MartinHopalongTight presets are well-formed', () {
    final m = F1030MartinHopalongTight();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1030MartinHopalongTight metadata is consistent', () {
    final m = F1030MartinHopalongTight();
    expect(m.metadata.id, m.id);
  });
}
