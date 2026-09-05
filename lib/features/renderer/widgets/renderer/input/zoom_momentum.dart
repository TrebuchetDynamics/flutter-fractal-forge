import 'dart:math' as math;

/// Logarithmic zoom inertia, calibrated to the existing 16 ms gesture step.
final class RendererZoomMomentum {
  const RendererZoomMomentum._();

  static const double _retention = 0.92;
  static const double _stopSpeed = 0.0001;

  /// Integrate fractional reference frames so delayed and high-refresh frames
  /// cover the same log2 zoom distance. Stop exactly at the velocity cutoff.
  static ({double logZoomDelta, double velocity}) advance(
    double velocity,
    Duration elapsed,
  ) {
    final speed = velocity.abs();
    if (!velocity.isFinite || speed <= _stopSpeed) {
      return (logZoomDelta: 0, velocity: 0);
    }
    if (elapsed <= Duration.zero) {
      return (logZoomDelta: 0, velocity: velocity);
    }
    final frames = elapsed.inMicroseconds / 16000;
    final stopFrames = math.log(_stopSpeed / speed) / math.log(_retention);
    final activeFrames = math.min(frames, stopFrames);
    final decay = math.pow(_retention, activeFrames).toDouble();
    final travel = _retention * (1 - decay) / (1 - _retention);
    return (
      logZoomDelta: velocity * 0.016 * travel,
      velocity: frames >= stopFrames ? 0 : velocity * decay,
    );
  }
}
