// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0425_seahorse_valley/f0425_seahorse_valley_module.dart';

void main() {
  test('F0425SeahorseValley instantiates', () {
    final m = F0425SeahorseValley();
    expect(m.id, 'f0425_seahorse_valley');
    expect(m.shader, 'shaders/f0425_seahorse_valley_gpu.frag');
  });

  test('F0425SeahorseValley presets are well-formed', () {
    final m = F0425SeahorseValley();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0425SeahorseValley metadata is consistent', () {
    final m = F0425SeahorseValley();
    expect(m.metadata.id, m.id);
  });
}
