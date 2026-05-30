// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0238_anti_ces_ro/f0238_anti_ces_ro_module.dart';

void main() {
  test('F0238AntiCesRo instantiates', () {
    final m = F0238AntiCesRo();
    expect(m.id, 'f0238_anti_ces_ro');
    expect(m.shader, 'shaders/f0238_anti_ces_ro_gpu.frag');
  });

  test('F0238AntiCesRo presets are well-formed', () {
    final m = F0238AntiCesRo();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0238AntiCesRo metadata is consistent', () {
    final m = F0238AntiCesRo();
    expect(m.metadata.id, m.id);
  });
}
