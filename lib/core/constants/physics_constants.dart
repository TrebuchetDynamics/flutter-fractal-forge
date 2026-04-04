import 'package:flutter/animation.dart';

/// Physics constants for gesture handling.
///
/// These values control momentum, friction, and thresholds for pan, zoom,
/// and gesture detection. Based on Google Maps-style fling behavior.
abstract final class PhysicsConstants {
  // Momentum / friction (per-frame decay at 60fps, Google Maps spec)
  /// Zoom friction coefficient: velocity multiplier per frame.
  /// Google Maps spec: 0.92 per frame at 60fps.
  static const double zoomFriction = 0.92;

  /// Pan friction coefficient: velocity multiplier per frame.
  /// Google Maps spec: 0.95 per frame at 60fps.
  static const double panFriction = 0.95;

  // Velocity stop thresholds
  /// Minimum zoom velocity to keep momentum animation running (zoom levels/ms).
  static const double zoomVelocityThreshold = 0.0001;

  /// Minimum pan velocity to keep momentum animation running (px/frame).
  static const double panVelocityThreshold = 0.1;

  // Double-tap detection
  /// Maximum time gap between two taps to be considered a double-tap (ms).
  static const int doubleTapMaxGapMs = 280;

  /// Maximum distance between two taps to be considered a double-tap (px).
  static const double doubleTapMaxDistancePx = 28.0;

  // Fling thresholds
  /// Fling threshold: minimum velocity to trigger fling (px/frame).
  /// Corresponds to ~0.3 px/ms which is Google Maps spec.
  static const double flingVelocityThresholdPxPerFrame = 5.0;

  /// Zoom momentum threshold: minimum velocity to trigger zoom momentum (zoom levels/ms).
  static const double zoomMomentumThreshold = 0.01;

  // Animation durations
  /// Duration for pan fling animation.
  static const Duration panFlingDuration = Duration(seconds: 2);

  /// Duration for zoom momentum animation.
  static const Duration zoomMomentumDuration = Duration(seconds: 2);

  // Two-finger tap
  /// Maximum duration for a valid two-finger tap (ms).
  static const int twoFingerTapMaxDurationMs = 220;

  /// Maximum movement distance for a valid two-finger tap (px).
  static const double twoFingerTapMaxDistancePx = 18.0;

  // Zoom animation
  /// Duration for zoom animations (e.g., two-finger tap zoom out).
  static const Duration zoomAnimationDuration = Duration(milliseconds: 200);

  /// Duration for double-tap pan/zoom animation.
  static const Duration doubleTapAnimationDuration =
      Duration(milliseconds: 200);

  // Momentum controller durations
  /// Default zoom momentum controller duration.
  static const Duration zoomMomentumControllerDuration =
      Duration(milliseconds: 800);

  /// Default pan momentum controller duration.
  static const Duration panMomentumControllerDuration =
      Duration(milliseconds: 500);

  // Helper getters for Cubic curves used in auto-explore
  /// Cubic curve for cinematic pan animation.
  static const Cubic cinematicPanCurve = Cubic(0.22, 0.0, 0.15, 1.0);
}
