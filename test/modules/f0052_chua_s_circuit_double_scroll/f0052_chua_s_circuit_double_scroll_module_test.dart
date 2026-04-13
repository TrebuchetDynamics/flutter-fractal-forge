// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0052_chua_s_circuit_double_scroll/f0052_chua_s_circuit_double_scroll_module.dart';

void main() {
  test('F0052ChuaSCircuitDoubleScroll instantiates', () {
    final m = F0052ChuaSCircuitDoubleScroll();
    expect(m.id, 'f0052_chua_s_circuit_double_scroll');
    expect(m.shader, 'shaders/f0052_chua_s_circuit_double_scroll_gpu.frag');
  });

  test('F0052ChuaSCircuitDoubleScroll presets are well-formed', () {
    final m = F0052ChuaSCircuitDoubleScroll();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0052ChuaSCircuitDoubleScroll metadata is consistent', () {
    final m = F0052ChuaSCircuitDoubleScroll();
    expect(m.metadata.id, m.id);
  });
}
