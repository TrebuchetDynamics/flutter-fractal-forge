// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0420_gumowski_mira_propeller/f0420_gumowski_mira_propeller_module.dart';

void main() {
  test('F0420GumowskiMiraPropeller instantiates', () {
    final m = F0420GumowskiMiraPropeller();
    expect(m.id, 'f0420_gumowski_mira_propeller');
    expect(m.shader, 'shaders/f0420_gumowski_mira_propeller_gpu.frag');
  });

  test('F0420GumowskiMiraPropeller presets are well-formed', () {
    final m = F0420GumowskiMiraPropeller();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0420GumowskiMiraPropeller metadata is consistent', () {
    final m = F0420GumowskiMiraPropeller();
    expect(m.metadata.id, m.id);
  });
}
