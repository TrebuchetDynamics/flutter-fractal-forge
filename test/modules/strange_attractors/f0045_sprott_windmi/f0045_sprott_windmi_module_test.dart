// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0045_sprott_windmi/f0045_sprott_windmi_module.dart';

void main() {
  test('F0045SprottWindmi instantiates', () {
    final m = F0045SprottWindmi();
    expect(m.id, 'f0045_sprott_windmi');
    expect(m.shader, 'shaders/f0045_sprott_windmi_gpu.frag');
  });

  test('F0045SprottWindmi presets are well-formed', () {
    final m = F0045SprottWindmi();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0045SprottWindmi metadata is consistent', () {
    final m = F0045SprottWindmi();
    expect(m.metadata.id, m.id);
  });
}
