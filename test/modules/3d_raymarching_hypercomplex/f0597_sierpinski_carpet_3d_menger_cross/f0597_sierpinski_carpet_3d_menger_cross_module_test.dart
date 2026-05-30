// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0597_sierpinski_carpet_3d_menger_cross/f0597_sierpinski_carpet_3d_menger_cross_module.dart';

void main() {
  test('F0597SierpinskiCarpet3dMengerCross instantiates', () {
    final m = F0597SierpinskiCarpet3dMengerCross();
    expect(m.id, 'f0597_sierpinski_carpet_3d_menger_cross');
    expect(
        m.shader, 'shaders/f0597_sierpinski_carpet_3d_menger_cross_gpu.frag');
  });

  test('F0597SierpinskiCarpet3dMengerCross presets are well-formed', () {
    final m = F0597SierpinskiCarpet3dMengerCross();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0597SierpinskiCarpet3dMengerCross metadata is consistent', () {
    final m = F0597SierpinskiCarpet3dMengerCross();
    expect(m.metadata.id, m.id);
  });
}
