// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1046_svensson_wave/f1046_svensson_wave_module.dart';

void main() {
  test('F1046SvenssonWave instantiates', () {
    final m = F1046SvenssonWave();
    expect(m.id, 'f1046_svensson_wave');
    expect(m.shader, 'shaders/f1046_svensson_wave_gpu.frag');
  });

  test('F1046SvenssonWave presets are well-formed', () {
    final m = F1046SvenssonWave();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1046SvenssonWave metadata is consistent', () {
    final m = F1046SvenssonWave();
    expect(m.metadata.id, m.id);
  });
}
