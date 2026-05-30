// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1011_lowlife_b3_s13/f1011_lowlife_b3_s13_module.dart';

void main() {
  test('F1011LowlifeB3S13 instantiates', () {
    final m = F1011LowlifeB3S13();
    expect(m.id, 'f1011_lowlife_b3_s13');
    expect(m.shader, 'shaders/f1011_lowlife_b3_s13_gpu.frag');
  });

  test('F1011LowlifeB3S13 presets are well-formed', () {
    final m = F1011LowlifeB3S13();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1011LowlifeB3S13 metadata is consistent', () {
    final m = F1011LowlifeB3S13();
    expect(m.metadata.id, m.id);
  });
}
