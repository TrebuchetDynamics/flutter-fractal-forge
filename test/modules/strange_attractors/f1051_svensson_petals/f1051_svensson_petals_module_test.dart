// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1051_svensson_petals/f1051_svensson_petals_module.dart';

void main() {
  test('F1051SvenssonPetals instantiates', () {
    final m = F1051SvenssonPetals();
    expect(m.id, 'f1051_svensson_petals');
    expect(m.shader, 'shaders/f1051_svensson_petals_gpu.frag');
  });

  test('F1051SvenssonPetals presets are well-formed', () {
    final m = F1051SvenssonPetals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1051SvenssonPetals metadata is consistent', () {
    final m = F1051SvenssonPetals();
    expect(m.metadata.id, m.id);
  });
}
