// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0249_random_bush/f0249_random_bush_module.dart';

void main() {
  test('F0249RandomBush instantiates', () {
    final m = F0249RandomBush();
    expect(m.id, 'f0249_random_bush');
    expect(m.shader, 'shaders/f0249_random_bush_gpu.frag');
  });

  test('F0249RandomBush presets are well-formed', () {
    final m = F0249RandomBush();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0249RandomBush metadata is consistent', () {
    final m = F0249RandomBush();
    expect(m.metadata.id, m.id);
  });
}
