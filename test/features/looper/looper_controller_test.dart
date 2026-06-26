import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const a = LooperPose(
    x: 0,
    y: 0,
    z: 1,
    rotationX: 0,
    rotationY: 0,
    rotationZ: 0,
  );
  const b = LooperPose(
    x: 2,
    y: -2,
    z: 100,
    rotationX: 1,
    rotationY: 2,
    rotationZ: 3,
  );

  test('duration is capped to 15 seconds', () {
    final plan = LooperPlan(a: a, b: b, duration: const Duration(seconds: 99));

    expect(plan.duration, const Duration(seconds: 15));
    expect(plan.frameCount, 120);
  });

  test('poses move A to B and back', () {
    final plan = LooperPlan(a: a, b: b, duration: const Duration(seconds: 2));

    expect(plan.poseAtFrame(0).x, 0);
    expect(plan.poseAtFrame(plan.frameCount ~/ 2).x, closeTo(2, 0.3));
    expect(plan.poseAtFrame(plan.frameCount - 1).x, 0);
  });

  test('resets saved poses and preview when fractal changes', () {
    final registry = ModuleRegistry();
    final fractal = FractalController(registry);
    final looper = LooperController(controller: fractal);
    addTearDown(() {
      looper.dispose();
      fractal.dispose();
    });

    looper.setAFromCurrent();
    fractal.updateZoom(2);
    looper.setBFromCurrent();
    looper.play();

    final next = registry.modules.firstWhere((m) => m.id != fractal.module.id);
    fractal.selectModule(next, animate: false);

    expect(looper.a, isNull);
    expect(looper.b, isNull);
    expect(looper.canLoop, isFalse);
    expect(looper.isPlaying, isFalse);
  });
}
