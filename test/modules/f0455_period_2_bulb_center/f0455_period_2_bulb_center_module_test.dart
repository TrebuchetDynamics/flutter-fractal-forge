// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0455_period_2_bulb_center/f0455_period_2_bulb_center_module.dart';

void main() {
  test('F0455Period2BulbCenter instantiates', () {
    final m = F0455Period2BulbCenter();
    expect(m.id, 'f0455_period_2_bulb_center');
    expect(m.shader, 'shaders/f0455_period_2_bulb_center_gpu.frag');
  });

  test('F0455Period2BulbCenter presets are well-formed', () {
    final m = F0455Period2BulbCenter();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0455Period2BulbCenter metadata is consistent', () {
    final m = F0455Period2BulbCenter();
    expect(m.metadata.id, m.id);
  });
}
