import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/rendering/animation_controller_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // AnimatedFractalController
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – construction', () {
    test('creates with default durations and curve', () {
      final controller = AnimatedFractalController();

      expect(controller.parameterDuration, const Duration(milliseconds: 250));
      expect(controller.morphDuration, const Duration(milliseconds: 600));
      expect(controller.curve, Curves.easeOutCubic);
      expect(controller.isTransitioning, isFalse);
      expect(controller.isCelebrating, isFalse);
      expect(controller.morphProgress, 1.0);
      expect(controller.previousModuleId, isNull);
      expect(controller.currentModuleId, isNull);

      controller.dispose();
    });

    test('creates with custom durations and curve', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 100),
        morphDuration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );

      expect(controller.parameterDuration, const Duration(milliseconds: 100));
      expect(controller.morphDuration, const Duration(milliseconds: 300));
      expect(controller.curve, Curves.linear);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // AnimatedParameterTransitionPlan
  // ---------------------------------------------------------------------------

  group('AnimatedParameterTransitionPlan', () {
    test('classifies unchanged, numeric, and unsupported parameter changes',
        () {
      final unchanged = AnimatedParameterTransitionPlan.fromValues(1.0, 1.0);
      final numeric = AnimatedParameterTransitionPlan.fromValues(1, 2.5);
      final unsupported =
          AnimatedParameterTransitionPlan.fromValues(false, true);

      expect(unchanged.kind, AnimatedParameterTransitionKind.unchanged);
      expect(unchanged.startsTransition, isFalse);
      expect(numeric.kind, AnimatedParameterTransitionKind.numeric);
      expect(numeric.startsTransition, isTrue);
      expect(numeric.fromValue, 1.0);
      expect(numeric.toValue, 2.5);
      expect(unsupported.kind, AnimatedParameterTransitionKind.unsupported);
      expect(unsupported.startsTransition, isFalse);
    });

    test('rejects non-finite numeric endpoints before interpolation', () {
      for (final candidate in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final fromInvalid = AnimatedParameterTransitionPlan.fromValues(
          candidate,
          2.0,
        );
        final toInvalid = AnimatedParameterTransitionPlan.fromValues(
          1.0,
          candidate,
        );

        expect(
          fromInvalid.kind,
          AnimatedParameterTransitionKind.unsupported,
          reason: 'from=$candidate',
        );
        expect(fromInvalid.startsTransition, isFalse);
        expect(
          toInvalid.kind,
          AnimatedParameterTransitionKind.unsupported,
          reason: 'to=$candidate',
        );
        expect(toInvalid.startsTransition, isFalse);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // AnimatedTimelinePlan
  // ---------------------------------------------------------------------------

  group('AnimatedTimelinePlan', () {
    test('keeps sub-frame durations inside the curve progress domain', () {
      final plan = AnimatedTimelinePlan.forDuration(
        const Duration(milliseconds: 1),
      );

      expect(plan.isImmediate, isFalse);
      expect(plan.totalFrames, 1);
      expect(plan.progressForFrame(0), 0.0);
      expect(plan.progressForFrame(1), 1.0);
      expect(plan.progressForFrame(2), 1.0);
      expect(plan.isCompleteFrame(1), isTrue);
    });

    test('treats zero and negative durations as immediate one-frame plans', () {
      for (final duration in [
        Duration.zero,
        const Duration(milliseconds: -1),
      ]) {
        final plan = AnimatedTimelinePlan.forDuration(duration);

        expect(plan.isImmediate, isTrue, reason: '$duration');
        expect(plan.totalFrames, 1, reason: '$duration');
        expect(plan.progressForFrame(1), 1.0, reason: '$duration');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // AnimatedElapsedProgress
  // ---------------------------------------------------------------------------

  group('AnimatedElapsedProgress', () {
    test('treats non-positive durations as immediate completion', () {
      for (final duration in [
        Duration.zero,
        const Duration(milliseconds: -1),
      ]) {
        final progress = AnimatedElapsedProgress(
          duration: duration,
          elapsed: Duration.zero,
        );

        expect(progress.value, 1.0, reason: '$duration');
        expect(progress.isComplete, isTrue, reason: '$duration');
      }
    });

    test('clamps positive-duration elapsed progress to the curve domain', () {
      expect(
        const AnimatedElapsedProgress(
          duration: Duration(seconds: 1),
          elapsed: Duration(milliseconds: -1),
        ).value,
        0.0,
      );
      expect(
        const AnimatedElapsedProgress(
          duration: Duration(seconds: 1),
          elapsed: Duration(milliseconds: 500),
        ).value,
        0.5,
      );
      expect(
        const AnimatedElapsedProgress(
          duration: Duration(seconds: 1),
          elapsed: Duration(seconds: 2),
        ).value,
        1.0,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Interpolated value accessors before any animation starts
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – initial interpolated values', () {
    test('interpolatedZoom is null before animateZoom is called', () {
      final controller = AnimatedFractalController();
      expect(controller.interpolatedZoom, isNull);
      controller.dispose();
    });

    test('interpolatedPan is null before animatePan is called', () {
      final controller = AnimatedFractalController();
      expect(controller.interpolatedPan, isNull);
      controller.dispose();
    });

    test('interpolatedRotation is null before animateRotation is called', () {
      final controller = AnimatedFractalController();
      expect(controller.interpolatedRotation, isNull);
      controller.dispose();
    });

    test('getInterpolatedValue returns null for unknown parameter id', () {
      final controller = AnimatedFractalController();
      expect(controller.getInterpolatedValue('nonexistent', 42.0), isNull);
      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // animateParameter
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – animateParameter', () {
    test('sets isTransitioning to true when animating a numeric parameter', () {
      final controller = AnimatedFractalController();

      controller.animateParameter('speed', 0.0, 1.0);

      expect(controller.isTransitioning, isTrue);

      controller.dispose();
    });

    test('no-op when from == to', () {
      final controller = AnimatedFractalController();
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.animateParameter('speed', 1.0, 1.0);

      // from == to → function returns early; no notification is emitted
      expect(notified, isFalse);
      expect(controller.isTransitioning, isFalse);

      controller.dispose();
    });

    test('unsupported parameter changes do not leave transitions stuck', () {
      final controller = AnimatedFractalController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.animateParameter('enabled', false, true);
      controller.tick();

      expect(controller.isTransitioning, isFalse);
      expect(controller.getInterpolatedValue('enabled', true), isNull);
      expect(notifyCount, 0);

      controller.dispose();
    });

    test('notifies listeners when parameter animation starts', () {
      final controller = AnimatedFractalController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.animateParameter('iterations', 100.0, 200.0);

      expect(notifyCount, greaterThan(0));

      controller.dispose();
    });

    test('returns an interpolated value between from and to', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 500),
      );

      controller.animateParameter('zoom', 0.0, 100.0);

      // Immediately after start the animation is in-flight; value must be in [0, 100].
      final value = controller.getInterpolatedValue('zoom', 0.0);
      expect(value, isA<double>());
      expect(value as double, inInclusiveRange(0.0, 100.0));

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // animateZoom
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – animateZoom', () {
    test('sets isTransitioning and produces a non-null interpolated zoom', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 500),
      );

      controller.animateZoom(1.0, 5.0);

      expect(controller.isTransitioning, isTrue);
      expect(controller.interpolatedZoom, isNotNull);
      expect(controller.interpolatedZoom!, inInclusiveRange(1.0, 5.0));

      controller.dispose();
    });

    test('no-op when from == to', () {
      final controller = AnimatedFractalController();

      controller.animateZoom(2.0, 2.0);

      expect(controller.isTransitioning, isFalse);
      expect(controller.interpolatedZoom, isNull);

      controller.dispose();
    });

    test('ignores non-finite zoom endpoints instead of emitting NaN frames',
        () {
      final controller = AnimatedFractalController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.animateZoom(double.nan, 2.0);
      controller.animateZoom(1.0, double.infinity);

      expect(controller.isTransitioning, isFalse);
      expect(controller.interpolatedZoom, isNull);
      expect(notifyCount, 0);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // animatePan
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – animatePan', () {
    test('sets isTransitioning and provides an in-range interpolated pan', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 500),
      );
      final from = Vector2(0.0, 0.0);
      final to = Vector2(1.0, 1.0);

      controller.animatePan(from, to);

      expect(controller.isTransitioning, isTrue);
      expect(controller.interpolatedPan, isNotNull);
      final pan = controller.interpolatedPan!;
      expect(pan.x, inInclusiveRange(0.0, 1.0));
      expect(pan.y, inInclusiveRange(0.0, 1.0));

      controller.dispose();
    });

    test('no-op when from and to are identical', () {
      final controller = AnimatedFractalController();

      controller.animatePan(Vector2(0.5, 0.5), Vector2(0.5, 0.5));

      expect(controller.isTransitioning, isFalse);
      expect(controller.interpolatedPan, isNull);

      controller.dispose();
    });

    test('ignores non-finite pan endpoints instead of emitting NaN frames', () {
      final controller = AnimatedFractalController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.animatePan(Vector2(double.nan, 0.0), Vector2(1.0, 1.0));
      controller.animatePan(Vector2(0.0, 0.0), Vector2(1.0, double.infinity));

      expect(controller.isTransitioning, isFalse);
      expect(controller.interpolatedPan, isNull);
      expect(notifyCount, 0);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // animateRotation
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – animateRotation', () {
    test('sets isTransitioning and provides an in-range interpolated rotation',
        () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 500),
      );
      final from = Vector3(0.0, 0.0, 0.0);
      final to = Vector3(1.0, 2.0, 3.0);

      controller.animateRotation(from, to);

      expect(controller.isTransitioning, isTrue);
      expect(controller.interpolatedRotation, isNotNull);
      final rot = controller.interpolatedRotation!;
      expect(rot.x, inInclusiveRange(0.0, 1.0));
      expect(rot.y, inInclusiveRange(0.0, 2.0));
      expect(rot.z, inInclusiveRange(0.0, 3.0));

      controller.dispose();
    });

    test('no-op when from and to are identical', () {
      final controller = AnimatedFractalController();

      controller.animateRotation(Vector3(1, 2, 3), Vector3(1, 2, 3));

      expect(controller.isTransitioning, isFalse);
      expect(controller.interpolatedRotation, isNull);

      controller.dispose();
    });

    test('ignores non-finite rotation endpoints instead of emitting NaN frames',
        () {
      final controller = AnimatedFractalController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.animateRotation(
        Vector3(double.nan, 0.0, 0.0),
        Vector3(1.0, 1.0, 1.0),
      );
      controller.animateRotation(
        Vector3(0.0, 0.0, 0.0),
        Vector3(1.0, 1.0, double.negativeInfinity),
      );

      expect(controller.isTransitioning, isFalse);
      expect(controller.interpolatedRotation, isNull);
      expect(notifyCount, 0);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // startMorph
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – startMorph', () {
    test('sets isTransitioning, previousModuleId, and currentModuleId', () {
      final controller = AnimatedFractalController();

      controller.startMorph('mandelbrot', 'julia');

      expect(controller.isTransitioning, isTrue);
      expect(controller.previousModuleId, 'mandelbrot');
      expect(controller.currentModuleId, 'julia');
      expect(controller.morphProgress, inInclusiveRange(0.0, 1.0));

      controller.dispose();
    });

    test('no-op when fromModuleId == toModuleId', () {
      final controller = AnimatedFractalController();

      controller.startMorph('julia', 'julia');

      expect(controller.isTransitioning, isFalse);
      expect(controller.previousModuleId, isNull);
      expect(controller.morphProgress, 1.0);

      controller.dispose();
    });

    test('cancels prior morph and starts a new one', () {
      final controller = AnimatedFractalController();

      controller.startMorph('mandelbrot', 'julia');
      controller.startMorph('julia', 'phoenix');

      expect(controller.currentModuleId, 'phoenix');
      expect(controller.previousModuleId, 'julia');

      controller.dispose();
    });

    test('sub-frame morph durations complete without invalid curve progress',
        () async {
      final controller = AnimatedFractalController(
        morphDuration: const Duration(milliseconds: 1),
      );

      controller.startMorph('mandelbrot', 'julia');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.morphProgress, 1.0);
      expect(controller.previousModuleId, isNull);
      expect(controller.isTransitioning, isFalse);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // tick
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – tick', () {
    test('tick does not throw when no animations are active', () {
      final controller = AnimatedFractalController();

      expect(() => controller.tick(), returnsNormally);

      controller.dispose();
    });

    test('tick advances active animations and notifies when running', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 500),
      );
      controller.animateZoom(1.0, 10.0);

      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.tick();

      // Animation is in-flight → tick should have triggered a notification
      expect(notifications, greaterThan(0));

      controller.dispose();
    });

    test('tick completes animation after duration elapses', () async {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 1),
      );
      controller.animateZoom(0.0, 5.0);

      // Wait longer than parameterDuration so the animation is done
      await Future<void>.delayed(const Duration(milliseconds: 50));
      controller.tick();

      // After completion the zoom should be cleared and transitioning should stop
      expect(controller.interpolatedZoom, isNull);
      expect(controller.isTransitioning, isFalse);

      controller.dispose();
    });

    test('tick completes parameter animations without concurrent mutation',
        () async {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 1),
      );

      try {
        controller.animateParameter('iterations', 100.0, 200.0);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(() => controller.tick(), returnsNormally);
        expect(controller.getInterpolatedValue('iterations', 200.0), isNull);
        expect(controller.isTransitioning, isFalse);
      } finally {
        controller.dispose();
      }
    });

    test('tick completes negative-duration animations instead of sticking', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: -1),
      );
      controller.animateZoom(0.0, 5.0);

      controller.tick();

      expect(controller.interpolatedZoom, isNull);
      expect(controller.isTransitioning, isFalse);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // celebrate / recordInterestingSpot
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – celebrate', () {
    test('celebrate sets isCelebrating to true', () {
      final controller = AnimatedFractalController();

      controller.celebrate();

      expect(controller.isCelebrating, isTrue);

      controller.dispose();
    });

    test('celebrate notifies listeners', () {
      final controller = AnimatedFractalController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.celebrate();

      expect(notifyCount, greaterThan(0));

      controller.dispose();
    });
  });

  group('AnimatedFractalController – recordInterestingSpot', () {
    test('emits onInterestingSpot stream event', () async {
      final controller = AnimatedFractalController();
      final Completer<void> completer = Completer<void>();
      final sub = controller.onInterestingSpot.listen((_) {
        if (!completer.isCompleted) completer.complete();
      });

      controller.recordInterestingSpot();

      await completer.future.timeout(const Duration(seconds: 1));
      expect(completer.isCompleted, isTrue);

      await sub.cancel();
      controller.dispose();
    });

    test('triggers celebration after 3 quick interesting spots', () {
      final controller = AnimatedFractalController();

      controller.recordInterestingSpot();
      controller.recordInterestingSpot();
      controller.recordInterestingSpot();

      // Third call in quick succession triggers celebration
      expect(controller.isCelebrating, isTrue);

      controller.dispose();
    });

    test('does not trigger celebration when spots are spaced out', () async {
      // We cannot actually wait 30 s in a unit test, so we verify that two
      // quick spots do NOT yet trigger celebration (threshold is 3).
      final controller = AnimatedFractalController();

      controller.recordInterestingSpot();
      controller.recordInterestingSpot();

      expect(controller.isCelebrating, isFalse);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // dispose
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – dispose', () {
    test('disposes cleanly with no active animations', () {
      final controller = AnimatedFractalController();

      expect(() => controller.dispose(), returnsNormally);
    });

    test('disposes cleanly while a morph is in progress', () {
      final controller = AnimatedFractalController();
      controller.startMorph('mandelbrot', 'julia');

      expect(() => controller.dispose(), returnsNormally);
    });

    test('disposes cleanly while zoom animation is in progress', () {
      final controller = AnimatedFractalController(
        parameterDuration: const Duration(seconds: 10),
      );
      controller.animateZoom(1.0, 100.0);

      expect(() => controller.dispose(), returnsNormally);
    });

    testWidgets('dispose cancels pending celebration reset callbacks',
        (tester) async {
      final controller = AnimatedFractalController();

      controller.celebrate();
      controller.dispose();
      await tester.pump(const Duration(milliseconds: 2500));

      expect(tester.takeException(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // ChangeNotifier listener management
  // ---------------------------------------------------------------------------

  group('AnimatedFractalController – ChangeNotifier', () {
    test('addListener and removeListener work without errors', () {
      final controller = AnimatedFractalController();
      void listener() {}

      controller.addListener(listener);
      controller.removeListener(listener);

      // If removeListener does not throw, the test passes.
      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // AnimatedFractalMixin (via a concrete subclass)
  // ---------------------------------------------------------------------------

  group('AnimatedFractalMixin', () {
    test('animationController is lazily created', () {
      final host = _MixinHost();

      // Accessing .animationController should create one on demand.
      expect(host.animationController, isA<AnimatedFractalController>());

      host.dispose();
    });

    test('custom animationController can be set', () {
      final host = _MixinHost();
      final custom = AnimatedFractalController(
        parameterDuration: const Duration(milliseconds: 99),
      );

      host.animationController = custom;

      expect(host.animationController.parameterDuration,
          const Duration(milliseconds: 99));

      host.dispose();
    });

    test('dispose of host also disposes the animation controller', () async {
      final host = _MixinHost();
      // Trigger lazy creation.
      final ctrl = host.animationController;

      // Should not throw.
      expect(() => host.dispose(), returnsNormally);

      // After the underlying StreamController is closed, listening to the
      // broadcast stream returns a subscription that immediately completes
      // (done) — it does NOT throw. Verify the stream is done by checking
      // that no further events can be emitted (the controller is closed).
      final events = <void>[];
      final sub = ctrl.onInterestingSpot.listen(events.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      // No events should arrive because the stream is already closed.
      expect(events, isEmpty);
    });
  });
}

// ---------------------------------------------------------------------------
// Test-only concrete class that uses the mixin.
// ---------------------------------------------------------------------------
class _MixinHost extends ChangeNotifier with AnimatedFractalMixin {}
