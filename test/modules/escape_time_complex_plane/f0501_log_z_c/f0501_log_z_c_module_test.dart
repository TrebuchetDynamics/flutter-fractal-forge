// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0501_log_z_c/f0501_log_z_c_module.dart';

void main() {
  test('F0501LogZC instantiates', () {
    final m = F0501LogZC();
    expect(m.id, 'f0501_log_z_c');
    expect(m.shader, 'shaders/f0501_log_z_c_gpu.frag');
  });

  test('F0501LogZC presets are well-formed', () {
    final m = F0501LogZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0501LogZC metadata is consistent', () {
    final m = F0501LogZC();
    expect(m.metadata.id, m.id);
  });
}
