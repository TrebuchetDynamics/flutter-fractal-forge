// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0483_sunrise_valley/f0483_sunrise_valley_module.dart';

void main() {
  test('F0483SunriseValley instantiates', () {
    final m = F0483SunriseValley();
    expect(m.id, 'f0483_sunrise_valley');
    expect(m.shader, 'shaders/f0483_sunrise_valley_gpu.frag');
  });

  test('F0483SunriseValley presets are well-formed', () {
    final m = F0483SunriseValley();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0483SunriseValley metadata is consistent', () {
    final m = F0483SunriseValley();
    expect(m.metadata.id, m.id);
  });
}
