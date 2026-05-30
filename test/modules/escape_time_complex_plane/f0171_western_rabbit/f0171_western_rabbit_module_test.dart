// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0171_western_rabbit/f0171_western_rabbit_module.dart';

void main() {
  test('F0171WesternRabbit instantiates', () {
    final m = F0171WesternRabbit();
    expect(m.id, 'f0171_western_rabbit');
    expect(m.shader, 'shaders/f0171_western_rabbit_gpu.frag');
  });

  test('F0171WesternRabbit presets are well-formed', () {
    final m = F0171WesternRabbit();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0171WesternRabbit metadata is consistent', () {
    final m = F0171WesternRabbit();
    expect(m.metadata.id, m.id);
  });
}
