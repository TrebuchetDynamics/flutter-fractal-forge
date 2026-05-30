// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0347_clifford_web/f0347_clifford_web_module.dart';

void main() {
  test('F0347CliffordWeb instantiates', () {
    final m = F0347CliffordWeb();
    expect(m.id, 'f0347_clifford_web');
    expect(m.shader, 'shaders/f0347_clifford_web_gpu.frag');
  });

  test('F0347CliffordWeb presets are well-formed', () {
    final m = F0347CliffordWeb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0347CliffordWeb metadata is consistent', () {
    final m = F0347CliffordWeb();
    expect(m.metadata.id, m.id);
  });
}
