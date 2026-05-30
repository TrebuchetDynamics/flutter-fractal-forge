// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0469_bulbous_valley/f0469_bulbous_valley_module.dart';

void main() {
  test('F0469BulbousValley instantiates', () {
    final m = F0469BulbousValley();
    expect(m.id, 'f0469_bulbous_valley');
    expect(m.shader, 'shaders/f0469_bulbous_valley_gpu.frag');
  });

  test('F0469BulbousValley presets are well-formed', () {
    final m = F0469BulbousValley();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0469BulbousValley metadata is consistent', () {
    final m = F0469BulbousValley();
    expect(m.metadata.id, m.id);
  });
}
