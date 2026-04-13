// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0172_eastern_rabbit/f0172_eastern_rabbit_module.dart';

void main() {
  test('F0172EasternRabbit instantiates', () {
    final m = F0172EasternRabbit();
    expect(m.id, 'f0172_eastern_rabbit');
    expect(m.shader, 'shaders/f0172_eastern_rabbit_gpu.frag');
  });

  test('F0172EasternRabbit presets are well-formed', () {
    final m = F0172EasternRabbit();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0172EasternRabbit metadata is consistent', () {
    final m = F0172EasternRabbit();
    expect(m.metadata.id, m.id);
  });
}
