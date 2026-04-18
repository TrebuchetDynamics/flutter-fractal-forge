// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0877_prouhet_thue_morse_curve_l_system/f0877_prouhet_thue_morse_curve_l_system_module.dart';

void main() {
  test('F0877ProuhetThueMorseCurveLSystem instantiates', () {
    final m = F0877ProuhetThueMorseCurveLSystem();
    expect(m.id, 'f0877_prouhet_thue_morse_curve_l_system');
    expect(m.shader, 'shaders/f0877_prouhet_thue_morse_curve_l_system_gpu.frag');
  });

  test('F0877ProuhetThueMorseCurveLSystem presets are well-formed', () {
    final m = F0877ProuhetThueMorseCurveLSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0877ProuhetThueMorseCurveLSystem metadata is consistent', () {
    final m = F0877ProuhetThueMorseCurveLSystem();
    expect(m.metadata.id, m.id);
  });
}
