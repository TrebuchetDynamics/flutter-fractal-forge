import 'package:flutter_fractals/features/renderer/cpu/cpu_coloring.dart';
import 'package:flutter_test/flutter_test.dart';

// Classic Mandelbrot recurrence z -> z^2 + c, used to exercise escapeTime.
(double, double) _mandelbrot(double zx, double zy, double cx, double cy) =>
    (zx * zx - zy * zy + cx, 2.0 * zx * zy + cy);

void main() {
  group('palette', () {
    test('returns channels within [0, 255]', () {
      for (final t in [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]) {
        final (r, g, b) = palette(t);
        for (final c in [r, g, b]) {
          expect(c, greaterThanOrEqualTo(0.0));
          expect(c, lessThanOrEqualTo(255.0));
        }
      }
    });

    test('is approximately cyclic with period ~1', () {
      // The palette uses 6.28318 as an approximation of 2*pi, so its period in
      // t is ~1.0000008 rather than exactly 1. Over one unit that accumulates a
      // ~5e-6 rad phase error, i.e. sub-0.01 on the 0..255 channel scale.
      final a = palette(0.2);
      final b = palette(1.2);
      expect(b.$1, closeTo(a.$1, 0.01));
      expect(b.$2, closeTo(a.$2, 0.01));
      expect(b.$3, closeTo(a.$3, 0.01));
    });
  });

  group('smoothEscape', () {
    test('returns a fractional index in [0, 1)', () {
      for (var it = 1; it < 200; it += 17) {
        final v = smoothEscape(it: it, mag2: 16.0 + it.toDouble());
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThan(1.0));
      }
    });

    test('stays finite for degenerate magnitude (mag2 < 1, NaN guard)', () {
      // mag2 < 1 drives the inner log2 negative; the guard must keep it finite.
      expect(smoothEscape(it: 5, mag2: 0.0).isFinite, isTrue);
      expect(smoothEscape(it: 5, mag2: 0.5).isFinite, isTrue);
    });
  });

  group('escapeTime', () {
    test('interior point (origin) returns kInsideColor', () {
      final color = escapeTime(0.0, 0.0, 64, 2.0, _mandelbrot);
      expect(color, kInsideColor);
    });

    test('escaping point does not return kInsideColor', () {
      // c = (1, 1) escapes almost immediately.
      final color = escapeTime(1.0, 1.0, 64, 2.0, _mandelbrot);
      expect(color, isNot(kInsideColor));
      for (final c in [color.$1, color.$2, color.$3]) {
        expect(c.isFinite, isTrue);
      }
    });

    test('honours a custom initial z (Julia-style seeding)', () {
      // Same recurrence but seeded away from the origin should still produce a
      // finite, valid colour.
      final color = escapeTime(0.0, 0.0, 64, 2.0, _mandelbrot, zx0: 3.0);
      expect(color, isNot(kInsideColor));
    });
  });
}
