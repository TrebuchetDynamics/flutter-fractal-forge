// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1009_eightlife_b3_s238/f1009_eightlife_b3_s238_module.dart';

void main() {
  test('F1009EightlifeB3S238 instantiates', () {
    final m = F1009EightlifeB3S238();
    expect(m.id, 'f1009_eightlife_b3_s238');
    expect(m.shader, 'shaders/f1009_eightlife_b3_s238_gpu.frag');
  });

  test('F1009EightlifeB3S238 presets are well-formed', () {
    final m = F1009EightlifeB3S238();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1009EightlifeB3S238 metadata is consistent', () {
    final m = F1009EightlifeB3S238();
    expect(m.metadata.id, m.id);
  });
}
