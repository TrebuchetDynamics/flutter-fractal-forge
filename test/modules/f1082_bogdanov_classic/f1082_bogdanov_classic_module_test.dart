// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1082_bogdanov_classic/f1082_bogdanov_classic_module.dart';

void main() {
  test('F1082BogdanovClassic instantiates', () {
    final m = F1082BogdanovClassic();
    expect(m.id, 'f1082_bogdanov_classic');
    expect(m.shader, 'shaders/f1082_bogdanov_classic_gpu.frag');
  });

  test('F1082BogdanovClassic presets are well-formed', () {
    final m = F1082BogdanovClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1082BogdanovClassic metadata is consistent', () {
    final m = F1082BogdanovClassic();
    expect(m.metadata.id, m.id);
  });
}
