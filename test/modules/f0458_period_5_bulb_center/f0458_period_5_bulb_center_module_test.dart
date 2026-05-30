// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0458_period_5_bulb_center/f0458_period_5_bulb_center_module.dart';

void main() {
  test('F0458Period5BulbCenter instantiates', () {
    final m = F0458Period5BulbCenter();
    expect(m.id, 'f0458_period_5_bulb_center');
    expect(m.shader, 'shaders/f0458_period_5_bulb_center_gpu.frag');
  });

  test('F0458Period5BulbCenter presets are well-formed', () {
    final m = F0458Period5BulbCenter();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0458Period5BulbCenter metadata is consistent', () {
    final m = F0458Period5BulbCenter();
    expect(m.metadata.id, m.id);
  });
}
