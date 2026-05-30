// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0151_siegel_disk_julia/f0151_siegel_disk_julia_module.dart';

void main() {
  test('F0151SiegelDiskJulia instantiates', () {
    final m = F0151SiegelDiskJulia();
    expect(m.id, 'f0151_siegel_disk_julia');
    expect(m.shader, 'shaders/f0151_siegel_disk_julia_gpu.frag');
  });

  test('F0151SiegelDiskJulia presets are well-formed', () {
    final m = F0151SiegelDiskJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0151SiegelDiskJulia metadata is consistent', () {
    final m = F0151SiegelDiskJulia();
    expect(m.metadata.id, m.id);
  });
}
