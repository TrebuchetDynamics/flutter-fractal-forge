// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0187_spider_julia/f0187_spider_julia_module.dart';

void main() {
  test('F0187SpiderJulia instantiates', () {
    final m = F0187SpiderJulia();
    expect(m.id, 'f0187_spider_julia');
    expect(m.shader, 'shaders/f0187_spider_julia_gpu.frag');
  });

  test('F0187SpiderJulia presets are well-formed', () {
    final m = F0187SpiderJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0187SpiderJulia metadata is consistent', () {
    final m = F0187SpiderJulia();
    expect(m.metadata.id, m.id);
  });
}
