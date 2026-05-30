// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0328_wireworld/f0328_wireworld_module.dart';

void main() {
  test('F0328Wireworld instantiates', () {
    final m = F0328Wireworld();
    expect(m.id, 'f0328_wireworld');
    expect(m.shader, 'shaders/f0328_wireworld_gpu.frag');
  });

  test('F0328Wireworld presets are well-formed', () {
    final m = F0328Wireworld();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0328Wireworld metadata is consistent', () {
    final m = F0328Wireworld();
    expect(m.metadata.id, m.id);
  });
}
