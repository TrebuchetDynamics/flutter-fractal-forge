// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0397_icon_chaos_d3/f0397_icon_chaos_d3_module.dart';

void main() {
  test('F0397IconChaosD3 instantiates', () {
    final m = F0397IconChaosD3();
    expect(m.id, 'f0397_icon_chaos_d3');
    expect(m.shader, 'shaders/f0397_icon_chaos_d3_gpu.frag');
  });

  test('F0397IconChaosD3 presets are well-formed', () {
    final m = F0397IconChaosD3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0397IconChaosD3 metadata is consistent', () {
    final m = F0397IconChaosD3();
    expect(m.metadata.id, m.id);
  });
}
