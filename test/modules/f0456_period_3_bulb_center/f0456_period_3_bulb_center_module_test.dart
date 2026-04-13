// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0456_period_3_bulb_center/f0456_period_3_bulb_center_module.dart';

void main() {
  test('F0456Period3BulbCenter instantiates', () {
    final m = F0456Period3BulbCenter();
    expect(m.id, 'f0456_period_3_bulb_center');
    expect(m.shader, 'shaders/f0456_period_3_bulb_center_gpu.frag');
  });

  test('F0456Period3BulbCenter presets are well-formed', () {
    final m = F0456Period3BulbCenter();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0456Period3BulbCenter metadata is consistent', () {
    final m = F0456Period3BulbCenter();
    expect(m.metadata.id, m.id);
  });
}
