// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0006_halley_s_method/f0006_halley_s_method_module.dart';

void main() {
  test('F0006HalleySMethod instantiates', () {
    final m = F0006HalleySMethod();
    expect(m.id, 'f0006_halley_s_method');
    expect(m.shader, 'shaders/f0006_halley_s_method_gpu.frag');
  });

  test('F0006HalleySMethod presets are well-formed', () {
    final m = F0006HalleySMethod();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0006HalleySMethod metadata is consistent', () {
    final m = F0006HalleySMethod();
    expect(m.metadata.id, m.id);
  });
}
