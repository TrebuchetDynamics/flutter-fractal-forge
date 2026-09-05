import 'dart:math' as math;

import 'package:flutter_fractals/features/renderer/widgets/renderer/input/zoom_momentum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retains the established 16 ms zoom feel in both directions', () {
    for (final velocity in [0.08, -0.08]) {
      final step = RendererZoomMomentum.advance(
          velocity, const Duration(milliseconds: 16));
      expect(step.velocity, closeTo(velocity * 0.92, 1e-12));
      expect(step.logZoomDelta, closeTo(velocity * 0.92 * 0.016, 1e-12));
    }
  });

  test('equal elapsed time produces equal zoom across frame schedules', () {
    for (final initial in [0.02, -0.02, 0.1, -0.1]) {
      for (final total in [320000, 1280000, 2000000]) {
        final expected = RendererZoomMomentum.advance(
            initial, Duration(microseconds: total));
        for (final cadence in [8333, 16667, 33333, 100000]) {
          var velocity = initial;
          var travel = 0.0;
          var elapsed = 0;
          while (elapsed < total) {
            final dt = math.min(total - elapsed, cadence);
            final step = RendererZoomMomentum.advance(
                velocity, Duration(microseconds: dt));
            travel += step.logZoomDelta;
            velocity = step.velocity;
            elapsed += dt;
          }
          expect(travel, closeTo(expected.logZoomDelta, 1e-12));
          expect(velocity, closeTo(expected.velocity, 1e-12));
        }
      }
    }
  });

  test('zero-time ticks preserve velocity without moving', () {
    final step = RendererZoomMomentum.advance(0.1, Duration.zero);
    expect(step.logZoomDelta, 0);
    expect(step.velocity, 0.1);
  });

  test('rest, non-finite input and sub-threshold movement cannot drift', () {
    for (final velocity in [
      0.0,
      0.00001,
      -0.00001,
      double.nan,
      double.infinity
    ]) {
      final step =
          RendererZoomMomentum.advance(velocity, const Duration(seconds: 2));
      expect(step.logZoomDelta, 0);
      expect(step.velocity, 0);
    }
  });
}
