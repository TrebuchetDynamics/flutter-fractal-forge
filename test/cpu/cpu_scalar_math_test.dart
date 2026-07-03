import 'dart:math' as math;

import 'package:flutter_fractals/features/renderer/cpu/cpu_scalar_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('log2', () {
    test('matches math.log for positive input', () {
      expect(log2(8.0), closeTo(3.0, 1e-12));
      expect(log2(1.0), closeTo(0.0, 1e-12));
      expect(log2(0.5), closeTo(-1.0, 1e-12));
    });

    test('stays finite for zero and negative input (NaN guard)', () {
      // Regression: the nested log2(log2(m2)) in the smooth-escape colouring
      // path feeds a non-positive value into the outer log2 when m2 < 1.
      // Without the math.max(1e-16, x) guard this produced -Infinity/NaN that
      // propagated into palette colours.
      expect(log2(0.0).isFinite, isTrue);
      expect(log2(-5.0).isFinite, isTrue);
      // Nested form, the actual usage shape that previously broke.
      expect(log2(log2(0.5)).isFinite, isTrue);
    });
  });

  group('fract', () {
    test('returns the fractional part in [0, 1)', () {
      expect(fract(2.25), closeTo(0.25, 1e-12));
      expect(fract(-0.25), closeTo(0.75, 1e-12));
      expect(fract(3.0), closeTo(0.0, 1e-12));
    });
  });

  group('clampDouble', () {
    test('clamps to the inclusive range', () {
      expect(clampDouble(5.0, 0.0, 1.0), 1.0);
      expect(clampDouble(-5.0, 0.0, 1.0), 0.0);
      expect(clampDouble(0.5, 0.0, 1.0), 0.5);
    });
  });

  group('mix', () {
    test('interpolates linearly', () {
      expect(mix(0.0, 10.0, 0.25), closeTo(2.5, 1e-12));
      expect(mix(2.0, 4.0, 0.0), 2.0);
      expect(mix(2.0, 4.0, 1.0), 4.0);
    });
  });

  group('smoothstep', () {
    test('hermite-smooths between the edges', () {
      expect(smoothstep(0.0, 1.0, -1.0), 0.0);
      expect(smoothstep(0.0, 1.0, 2.0), 1.0);
      expect(smoothstep(0.0, 1.0, 0.5), closeTo(0.5, 1e-12));
    });

    test('degenerate edges return a hard step instead of NaN', () {
      expect(smoothstep(1.0, 1.0, 0.5), 0.0);
      expect(smoothstep(1.0, 1.0, 1.0), 1.0);
      expect(smoothstep(1.0, 1.0, 2.0), 1.0);
    });
  });

  group('floorMod', () {
    test('result takes the sign of the divisor', () {
      expect(floorMod(5.0, 3.0), closeTo(2.0, 1e-12));
      expect(floorMod(-1.0, 3.0), closeTo(2.0, 1e-12));
      expect(floorMod(1.0, -3.0), closeTo(-2.0, 1e-12));
    });
  });

  group('hyperbolic helpers', () {
    test('match dart:math reference values', () {
      for (final x in [-2.0, -0.5, 0.0, 0.75, 3.0]) {
        final expectedSinh = (math.exp(x) - math.exp(-x)) * 0.5;
        final expectedCosh = (math.exp(x) + math.exp(-x)) * 0.5;
        expect(sinh(x), closeTo(expectedSinh, 1e-9));
        expect(cosh(x), closeTo(expectedCosh, 1e-9));
        expect(tanh(x), closeTo(expectedSinh / expectedCosh, 1e-9));
      }
    });

    test('tanh saturates without overflow at large magnitudes', () {
      expect(tanh(50.0), closeTo(1.0, 1e-9));
      expect(tanh(-50.0), closeTo(-1.0, 1e-9));
    });
  });
}
