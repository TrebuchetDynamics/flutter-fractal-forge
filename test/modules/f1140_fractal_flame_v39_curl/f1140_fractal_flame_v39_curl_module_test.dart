// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1140_fractal_flame_v39_curl/f1140_fractal_flame_v39_curl_module.dart';

void main() {
  test('F1140FractalFlameV39Curl instantiates', () {
    final m = F1140FractalFlameV39Curl();
    expect(m.id, 'f1140_fractal_flame_v39_curl');
    expect(m.shader, 'shaders/f1140_fractal_flame_v39_curl_gpu.frag');
  });

  test('F1140FractalFlameV39Curl presets are well-formed', () {
    final m = F1140FractalFlameV39Curl();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1140FractalFlameV39Curl metadata is consistent', () {
    final m = F1140FractalFlameV39Curl();
    expect(m.metadata.id, m.id);
  });
}
