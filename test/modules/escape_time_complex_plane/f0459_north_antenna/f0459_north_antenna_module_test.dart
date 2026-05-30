// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0459_north_antenna/f0459_north_antenna_module.dart';

void main() {
  test('F0459NorthAntenna instantiates', () {
    final m = F0459NorthAntenna();
    expect(m.id, 'f0459_north_antenna');
    expect(m.shader, 'shaders/f0459_north_antenna_gpu.frag');
  });

  test('F0459NorthAntenna presets are well-formed', () {
    final m = F0459NorthAntenna();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0459NorthAntenna metadata is consistent', () {
    final m = F0459NorthAntenna();
    expect(m.metadata.id, m.id);
  });
}
