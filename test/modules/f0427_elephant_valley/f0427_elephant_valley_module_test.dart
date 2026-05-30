// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0427_elephant_valley/f0427_elephant_valley_module.dart';

void main() {
  test('F0427ElephantValley instantiates', () {
    final m = F0427ElephantValley();
    expect(m.id, 'f0427_elephant_valley');
    expect(m.shader, 'shaders/f0427_elephant_valley_gpu.frag');
  });

  test('F0427ElephantValley presets are well-formed', () {
    final m = F0427ElephantValley();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0427ElephantValley metadata is consistent', () {
    final m = F0427ElephantValley();
    expect(m.metadata.id, m.id);
  });
}
