// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0767_bolzano_non_differentiable/f0767_bolzano_non_differentiable_module.dart';

void main() {
  test('F0767BolzanoNonDifferentiable instantiates', () {
    final m = F0767BolzanoNonDifferentiable();
    expect(m.id, 'f0767_bolzano_non_differentiable');
    expect(m.shader, 'shaders/f0767_bolzano_non_differentiable_gpu.frag');
  });

  test('F0767BolzanoNonDifferentiable presets are well-formed', () {
    final m = F0767BolzanoNonDifferentiable();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0767BolzanoNonDifferentiable metadata is consistent', () {
    final m = F0767BolzanoNonDifferentiable();
    expect(m.metadata.id, m.id);
  });
}
