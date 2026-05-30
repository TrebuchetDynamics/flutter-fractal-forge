// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0691_pinwheel_tiling/f0691_pinwheel_tiling_module.dart';

void main() {
  test('F0691PinwheelTiling instantiates', () {
    final m = F0691PinwheelTiling();
    expect(m.id, 'f0691_pinwheel_tiling');
    expect(m.shader, 'shaders/f0691_pinwheel_tiling_gpu.frag');
  });

  test('F0691PinwheelTiling presets are well-formed', () {
    final m = F0691PinwheelTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0691PinwheelTiling metadata is consistent', () {
    final m = F0691PinwheelTiling();
    expect(m.metadata.id, m.id);
  });
}
