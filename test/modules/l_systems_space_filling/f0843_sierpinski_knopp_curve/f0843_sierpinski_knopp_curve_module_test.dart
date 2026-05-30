// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0843_sierpinski_knopp_curve/f0843_sierpinski_knopp_curve_module.dart';

void main() {
  test('F0843SierpinskiKnoppCurve instantiates', () {
    final m = F0843SierpinskiKnoppCurve();
    expect(m.id, 'f0843_sierpinski_knopp_curve');
    expect(m.shader, 'shaders/f0843_sierpinski_knopp_curve_gpu.frag');
  });

  test('F0843SierpinskiKnoppCurve presets are well-formed', () {
    final m = F0843SierpinskiKnoppCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0843SierpinskiKnoppCurve metadata is consistent', () {
    final m = F0843SierpinskiKnoppCurve();
    expect(m.metadata.id, m.id);
  });
}
