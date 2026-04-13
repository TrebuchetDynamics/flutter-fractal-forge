// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0529_siegel_disk_golden/f0529_siegel_disk_golden_module.dart';

void main() {
  test('F0529SiegelDiskGolden instantiates', () {
    final m = F0529SiegelDiskGolden();
    expect(m.id, 'f0529_siegel_disk_golden');
    expect(m.shader, 'shaders/f0529_siegel_disk_golden_gpu.frag');
  });

  test('F0529SiegelDiskGolden presets are well-formed', () {
    final m = F0529SiegelDiskGolden();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0529SiegelDiskGolden metadata is consistent', () {
    final m = F0529SiegelDiskGolden();
    expect(m.metadata.id, m.id);
  });
}
