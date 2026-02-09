import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/shaders/uniform_schema.dart';

void main() {
  test('UniformSchema assigns deterministic indices', () {
    final s = UniformSchema.build((b) {
      b.float('uTime');        // 0
      b.vec2('uResolution');   // 1-2
      b.vec2('uCenter');       // 3-4
      b.float('uZoom');        // 5
      b.float('uIterations');  // 6
    });

    expect(s['uTime'].index, 0);
    expect(s['uResolution'].index, 1);
    expect(s['uCenter'].index, 3);
    expect(s['uZoom'].index, 5);
    expect(s['uIterations'].index, 6);
    expect(s.floatCount, 7);
  });

  test('UniformSchema rejects duplicates', () {
    expect(
      () => UniformSchema.build((b) {
        b.float('a');
        b.vec2('a');
      }),
      throwsArgumentError,
    );
  });
}
