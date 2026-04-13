// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0131_phoenix_d_2/f0131_phoenix_d_2_module.dart';

void main() {
  test('F0131PhoenixD2 instantiates', () {
    final m = F0131PhoenixD2();
    expect(m.id, 'f0131_phoenix_d_2');
    expect(m.shader, 'shaders/f0131_phoenix_d_2_gpu.frag');
  });

  test('F0131PhoenixD2 presets are well-formed', () {
    final m = F0131PhoenixD2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0131PhoenixD2 metadata is consistent', () {
    final m = F0131PhoenixD2();
    expect(m.metadata.id, m.id);
  });
}
