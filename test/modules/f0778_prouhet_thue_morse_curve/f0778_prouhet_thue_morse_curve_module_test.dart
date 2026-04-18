// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0778_prouhet_thue_morse_curve/f0778_prouhet_thue_morse_curve_module.dart';

void main() {
  test('F0778ProuhetThueMorseCurve instantiates', () {
    final m = F0778ProuhetThueMorseCurve();
    expect(m.id, 'f0778_prouhet_thue_morse_curve');
    expect(m.shader, 'shaders/f0778_prouhet_thue_morse_curve_gpu.frag');
  });

  test('F0778ProuhetThueMorseCurve presets are well-formed', () {
    final m = F0778ProuhetThueMorseCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0778ProuhetThueMorseCurve metadata is consistent', () {
    final m = F0778ProuhetThueMorseCurve();
    expect(m.metadata.id, m.id);
  });
}
