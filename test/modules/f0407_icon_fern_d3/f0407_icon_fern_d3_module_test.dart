// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0407_icon_fern_d3/f0407_icon_fern_d3_module.dart';

void main() {
  test('F0407IconFernD3 instantiates', () {
    final m = F0407IconFernD3();
    expect(m.id, 'f0407_icon_fern_d3');
    expect(m.shader, 'shaders/f0407_icon_fern_d3_gpu.frag');
  });

  test('F0407IconFernD3 presets are well-formed', () {
    final m = F0407IconFernD3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0407IconFernD3 metadata is consistent', () {
    final m = F0407IconFernD3();
    expect(m.metadata.id, m.id);
  });
}
