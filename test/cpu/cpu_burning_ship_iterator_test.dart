import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu/cpu_iterators.dart';

void main() {
  group('CPU Burning Ship iterator', () {
    test('uses the shader-flipped parameter plane for escape metrics', () {
      final iterator = proxyIteratorForModule('burning_ship');

      // The Burning Ship shader/formula flips display Y before iterating so the
      // upright ship occupies positive screen Y. This coordinate is interior in
      // that flipped parameter plane but escapes quickly if raw Y is used.
      final uprightInterior = iterator(0.5, 1.1, 160, 4.0, Vector2.zero());
      final oppositeLobe = iterator(0.5, -1.1, 160, 4.0, Vector2.zero());

      expect(uprightInterior.escaped, isFalse);
      expect(uprightInterior.it, 160);
      expect(oppositeLobe.escaped, isTrue);
      expect(oppositeLobe.it, lessThan(10));
    });
  });
}
