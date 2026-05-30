// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0554_dual_quaternion_mandelbrot_extra/f0554_dual_quaternion_mandelbrot_extra_module.dart';

void main() {
  test('F0554DualQuaternionMandelbrotExtra instantiates', () {
    final m = F0554DualQuaternionMandelbrotExtra();
    expect(m.id, 'f0554_dual_quaternion_mandelbrot_extra');
    expect(m.shader, 'shaders/f0554_dual_quaternion_mandelbrot_extra_gpu.frag');
  });

  test('F0554DualQuaternionMandelbrotExtra presets are well-formed', () {
    final m = F0554DualQuaternionMandelbrotExtra();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0554DualQuaternionMandelbrotExtra metadata is consistent', () {
    final m = F0554DualQuaternionMandelbrotExtra();
    expect(m.metadata.id, m.id);
  });
}
