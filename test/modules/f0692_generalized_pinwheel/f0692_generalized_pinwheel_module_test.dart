// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0692_generalized_pinwheel/f0692_generalized_pinwheel_module.dart';

void main() {
  test('F0692GeneralizedPinwheel instantiates', () {
    final m = F0692GeneralizedPinwheel();
    expect(m.id, 'f0692_generalized_pinwheel');
    expect(m.shader, 'shaders/f0692_generalized_pinwheel_gpu.frag');
  });

  test('F0692GeneralizedPinwheel presets are well-formed', () {
    final m = F0692GeneralizedPinwheel();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0692GeneralizedPinwheel metadata is consistent', () {
    final m = F0692GeneralizedPinwheel();
    expect(m.metadata.id, m.id);
  });
}
