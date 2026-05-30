// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0774_rudin_shapiro_sequence/f0774_rudin_shapiro_sequence_module.dart';

void main() {
  test('F0774RudinShapiroSequence instantiates', () {
    final m = F0774RudinShapiroSequence();
    expect(m.id, 'f0774_rudin_shapiro_sequence');
    expect(m.shader, 'shaders/f0774_rudin_shapiro_sequence_gpu.frag');
  });

  test('F0774RudinShapiroSequence presets are well-formed', () {
    final m = F0774RudinShapiroSequence();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0774RudinShapiroSequence metadata is consistent', () {
    final m = F0774RudinShapiroSequence();
    expect(m.metadata.id, m.id);
  });
}
