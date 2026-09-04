import 'package:flutter_fractals/features/renderer/widgets/renderer/input/pan_momentum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves the existing 16 ms pan step', () {
    final step = RendererPanMomentum.advance(
        const Offset(20, -10), const Duration(milliseconds: 16));
    expect(step.velocity, const Offset(19, -9.5));
    expect(step.displacement.dx, closeTo(19, 1e-10));
    expect(step.displacement.dy, closeTo(-9.5, 1e-10));
  });

  test('equal elapsed time gives equal travel across frame schedules', () {
    const initial = Offset(20, -10);
    for (final total in [320000, 1280000, 2000000]) {
      final expected =
          RendererPanMomentum.advance(initial, Duration(microseconds: total));
      for (final cadence in [8333, 16667, 33333, 100000]) {
        var velocity = initial;
        var displacement = Offset.zero;
        var elapsed = 0;
        while (elapsed < total) {
          final dt = (total - elapsed).clamp(0, cadence);
          final step =
              RendererPanMomentum.advance(velocity, Duration(microseconds: dt));
          displacement += step.displacement;
          velocity = step.velocity;
          elapsed += dt;
        }
        expect(displacement.dx, closeTo(expected.displacement.dx, 1e-8),
            reason: 'total=$total, cadence=$cadence');
        expect(displacement.dy, closeTo(expected.displacement.dy, 1e-8));
        expect(velocity.dx, closeTo(expected.velocity.dx, 1e-8));
        expect(velocity.dy, closeTo(expected.velocity.dy, 1e-8));
      }
    }
  });

  test('zero elapsed time does not move or decay an active fling', () {
    final step =
        RendererPanMomentum.advance(const Offset(10, 0), Duration.zero);
    expect(step.displacement, Offset.zero);
    expect(step.velocity, const Offset(10, 0));
  });

  test('rest and slow movement stop without drifting', () {
    for (final velocity in [Offset.zero, const Offset(0.06, -0.06)]) {
      final step =
          RendererPanMomentum.advance(velocity, const Duration(seconds: 1));
      expect(step.displacement, Offset.zero);
      expect(step.velocity, Offset.zero);
    }
  });
}
