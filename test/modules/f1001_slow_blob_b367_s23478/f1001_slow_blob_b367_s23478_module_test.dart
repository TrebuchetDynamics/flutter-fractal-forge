// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1001_slow_blob_b367_s23478/f1001_slow_blob_b367_s23478_module.dart';

void main() {
  test('F1001SlowBlobB367S23478 instantiates', () {
    final m = F1001SlowBlobB367S23478();
    expect(m.id, 'f1001_slow_blob_b367_s23478');
    expect(m.shader, 'shaders/f1001_slow_blob_b367_s23478_gpu.frag');
  });

  test('F1001SlowBlobB367S23478 presets are well-formed', () {
    final m = F1001SlowBlobB367S23478();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1001SlowBlobB367S23478 metadata is consistent', () {
    final m = F1001SlowBlobB367S23478();
    expect(m.metadata.id, m.id);
  });
}
