// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0530_siegel_disk_silver/f0530_siegel_disk_silver_module.dart';

void main() {
  test('F0530SiegelDiskSilver instantiates', () {
    final m = F0530SiegelDiskSilver();
    expect(m.id, 'f0530_siegel_disk_silver');
    expect(m.shader, 'shaders/f0530_siegel_disk_silver_gpu.frag');
  });

  test('F0530SiegelDiskSilver presets are well-formed', () {
    final m = F0530SiegelDiskSilver();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0530SiegelDiskSilver metadata is consistent', () {
    final m = F0530SiegelDiskSilver();
    expect(m.metadata.id, m.id);
  });
}
