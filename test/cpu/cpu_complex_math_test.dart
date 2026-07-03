import 'dart:math' as math;

import 'package:flutter_fractals/features/renderer/cpu/cpu_complex_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cmul', () {
    test('multiplies complex numbers', () {
      // (1+2i)(3+4i) = -5 + 10i
      final p = cmul(1.0, 2.0, 3.0, 4.0);
      expect(p.$1, closeTo(-5.0, 1e-12));
      expect(p.$2, closeTo(10.0, 1e-12));
    });

    test('i * i == -1', () {
      final p = cmul(0.0, 1.0, 0.0, 1.0);
      expect(p.$1, closeTo(-1.0, 1e-12));
      expect(p.$2, closeTo(0.0, 1e-12));
    });
  });

  group('cdivSafe', () {
    test('divides complex numbers', () {
      // (1+2i)/(3+4i) = 0.44 + 0.08i
      final q = cdivSafe(1.0, 2.0, 3.0, 4.0);
      expect(q.$1, closeTo(0.44, 1e-12));
      expect(q.$2, closeTo(0.08, 1e-12));
    });

    test('stays finite when the denominator is zero', () {
      final q = cdivSafe(1.0, 1.0, 0.0, 0.0);
      expect(q.$1.isFinite, isTrue);
      expect(q.$2.isFinite, isTrue);
    });
  });

  group('clogSafe', () {
    test('matches polar log for a positive real', () {
      // log(e) = 1 + 0i
      final l = clogSafe(math.e, 0.0);
      expect(l.$1, closeTo(1.0, 1e-12));
      expect(l.$2, closeTo(0.0, 1e-12));
    });

    test('stays finite at the origin (log(0) guard)', () {
      final l = clogSafe(0.0, 0.0);
      expect(l.$1.isFinite, isTrue);
      expect(l.$2.isFinite, isTrue);
    });
  });

  group('cexpSafe', () {
    test('matches Euler identity exp(i*pi) == -1', () {
      final e = cexpSafe(0.0, math.pi);
      expect(e.$1, closeTo(-1.0, 1e-12));
      expect(e.$2, closeTo(0.0, 1e-12));
    });

    test('clamps the real part to avoid exp overflow', () {
      final e = cexpSafe(1000.0, 0.0);
      expect(e.$1.isFinite, isTrue);
      expect(e.$2.isFinite, isTrue);
    });
  });

  group('cpowSafe', () {
    test('squares via a^2 == a*a for a non-trivial complex value', () {
      const ax = 0.6, ay = -0.8;
      final viaPow = cpowSafe(ax, ay, 2.0, 0.0);
      final viaMul = cmul(ax, ay, ax, ay);
      expect(viaPow.$1, closeTo(viaMul.$1, 1e-9));
      expect(viaPow.$2, closeTo(viaMul.$2, 1e-9));
    });
  });

  group('cpowInt', () {
    test('z^0 == 1', () {
      final p = cpowInt(2.0, 3.0, 0);
      expect(p.$1, 1.0);
      expect(p.$2, 0.0);
    });

    test('z^3 matches repeated multiplication', () {
      const zx = 0.5, zy = -1.1;
      final z2 = cmul(zx, zy, zx, zy);
      final z3 = cmul(z2.$1, z2.$2, zx, zy);
      final p = cpowInt(zx, zy, 3);
      expect(p.$1, closeTo(z3.$1, 1e-12));
      expect(p.$2, closeTo(z3.$2, 1e-12));
    });
  });
}
