import 'dart:ui' show Offset;

/// Replayable decision for the renderer's two-finger tap shortcut.
///
/// The gesture mixin receives raw pointer-up and pointer-cancel events through
/// the same cleanup path. Keeping the acceptance criteria pure makes event-order
/// assumptions visible in focused tests instead of hiding them behind timers,
/// haptics, and animation side effects.
final class RendererTwoFingerTapDecision {
  static const int maxDurationMs = 220;

  const RendererTwoFingerTapDecision._({required this.midpoint});

  final Offset? midpoint;

  bool get shouldTrigger => midpoint != null;

  static RendererTwoFingerTapDecision evaluate({
    required bool isPointerUp,
    required bool candidate,
    required int activePointerCount,
    required Duration? elapsed,
    required Iterable<Offset> activePositions,
  }) {
    if (!isPointerUp ||
        !candidate ||
        activePointerCount != 2 ||
        elapsed == null) {
      return const RendererTwoFingerTapDecision._(midpoint: null);
    }
    if (elapsed.inMilliseconds > maxDurationMs) {
      return const RendererTwoFingerTapDecision._(midpoint: null);
    }

    final points = activePositions.toList(growable: false);
    if (points.length != 2) {
      return const RendererTwoFingerTapDecision._(midpoint: null);
    }

    return RendererTwoFingerTapDecision._(
      midpoint: Offset(
        (points[0].dx + points[1].dx) / 2.0,
        (points[0].dy + points[1].dy) / 2.0,
      ),
    );
  }
}
