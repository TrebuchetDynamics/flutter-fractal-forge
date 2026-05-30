// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0364_clifford_scroll/f0364_clifford_scroll_module.dart';

void main() {
  test('F0364CliffordScroll instantiates', () {
    final m = F0364CliffordScroll();
    expect(m.id, 'f0364_clifford_scroll');
    expect(m.shader, 'shaders/f0364_clifford_scroll_gpu.frag');
  });

  test('F0364CliffordScroll presets are well-formed', () {
    final m = F0364CliffordScroll();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0364CliffordScroll metadata is consistent', () {
    final m = F0364CliffordScroll();
    expect(m.metadata.id, m.id);
  });
}
