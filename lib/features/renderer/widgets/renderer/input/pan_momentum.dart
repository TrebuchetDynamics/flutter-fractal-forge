import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Elapsed-time pan inertia, calibrated to the existing 16 ms gesture cadence.
final class RendererPanMomentum {
  const RendererPanMomentum._();

  static const double _retention = 0.95;
  static const double _stopSpeed = 0.1;

  /// Velocity is in pixels per reference frame. Integrate the geometric decay
  /// over fractional frames, stopping exactly when the speed reaches the cutoff.
  static ({Offset displacement, Offset velocity}) advance(
    Offset velocity,
    Duration elapsed,
  ) {
    final speed = velocity.distance;
    if (speed <= _stopSpeed) {
      return (displacement: Offset.zero, velocity: Offset.zero);
    }
    if (elapsed <= Duration.zero) {
      return (displacement: Offset.zero, velocity: velocity);
    }
    final frames = elapsed.inMicroseconds / 16000;
    final stopFrames = math.log(_stopSpeed / speed) / math.log(_retention);
    final activeFrames = math.min(frames, stopFrames);
    final decay = math.pow(_retention, activeFrames).toDouble();
    final travel = _retention * (1 - decay) / (1 - _retention);
    return (
      displacement: velocity * travel,
      velocity: frames >= stopFrames ? Offset.zero : velocity * decay,
    );
  }
}
