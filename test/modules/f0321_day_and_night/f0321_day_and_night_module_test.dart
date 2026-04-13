// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0321_day_and_night/f0321_day_and_night_module.dart';

void main() {
  test('F0321DayAndNight instantiates', () {
    final m = F0321DayAndNight();
    expect(m.id, 'f0321_day_and_night');
    expect(m.shader, 'shaders/f0321_day_and_night_gpu.frag');
  });

  test('F0321DayAndNight presets are well-formed', () {
    final m = F0321DayAndNight();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0321DayAndNight metadata is consistent', () {
    final m = F0321DayAndNight();
    expect(m.metadata.id, m.id);
  });
}
