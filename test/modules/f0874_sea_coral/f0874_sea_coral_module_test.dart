// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0874_sea_coral/f0874_sea_coral_module.dart';

void main() {
  test('F0874SeaCoral instantiates', () {
    final m = F0874SeaCoral();
    expect(m.id, 'f0874_sea_coral');
    expect(m.shader, 'shaders/f0874_sea_coral_gpu.frag');
  });

  test('F0874SeaCoral presets are well-formed', () {
    final m = F0874SeaCoral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0874SeaCoral metadata is consistent', () {
    final m = F0874SeaCoral();
    expect(m.metadata.id, m.id);
  });
}
