// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0062_burke_shaw/f0062_burke_shaw_module.dart';

void main() {
  test('F0062BurkeShaw instantiates', () {
    final m = F0062BurkeShaw();
    expect(m.id, 'f0062_burke_shaw');
    expect(m.shader, 'shaders/f0062_burke_shaw_gpu.frag');
  });

  test('F0062BurkeShaw presets are well-formed', () {
    final m = F0062BurkeShaw();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0062BurkeShaw metadata is consistent', () {
    final m = F0062BurkeShaw();
    expect(m.metadata.id, m.id);
  });
}
