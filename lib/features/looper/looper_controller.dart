import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:vector_math/vector_math.dart';

@immutable
class LooperPose {
  final double x;
  final double y;
  final double z;
  final double rotationX;
  final double rotationY;
  final double rotationZ;

  const LooperPose({
    required this.x,
    required this.y,
    required this.z,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });

  factory LooperPose.fromView(FractalViewState view) {
    final pan = view.pan;
    final rotation = view.rotation;
    return LooperPose(
      x: pan.x,
      y: pan.y,
      z: view.zoom,
      rotationX: rotation.x,
      rotationY: rotation.y,
      rotationZ: rotation.z,
    );
  }

  FractalViewState toView() => FractalViewState(
        pan: Vector2(x, y),
        zoom: z,
        rotation: Vector3(rotationX, rotationY, rotationZ),
      );

  static LooperPose lerp(LooperPose a, LooperPose b, double t) {
    final clamped = t.clamp(0.0, 1.0);
    double mix(double start, double end) => start + (end - start) * clamped;
    return LooperPose(
      x: mix(a.x, b.x),
      y: mix(a.y, b.y),
      z: math.exp(mix(math.log(a.z), math.log(b.z))),
      rotationX: mix(a.rotationX, b.rotationX),
      rotationY: mix(a.rotationY, b.rotationY),
      rotationZ: mix(a.rotationZ, b.rotationZ),
    );
  }
}

class LooperPlan {
  static const Duration maxDuration = Duration(seconds: 15);
  static const Duration minDuration = Duration(seconds: 1);
  static const int exportFps = 8;

  final LooperPose a;
  final LooperPose b;
  final Duration duration;

  LooperPlan({
    required this.a,
    required this.b,
    required Duration duration,
  }) : duration = cappedDuration(duration);

  int get frameCount =>
      (duration.inMilliseconds * exportFps / 1000).round().clamp(2, 120);

  LooperPose poseAtFrame(int frameIndex) {
    final count = frameCount;
    final phase = count <= 1 ? 0.0 : frameIndex / (count - 1);
    final t = phase <= 0.5 ? phase * 2.0 : (1.0 - phase) * 2.0;
    return LooperPose.lerp(a, b, t);
  }

  static Duration cappedDuration(Duration value) {
    if (value < minDuration) return minDuration;
    if (value > maxDuration) return maxDuration;
    return value;
  }
}

class LooperController extends ChangeNotifier {
  final FractalController controller;
  LooperPose? _a;
  LooperPose? _b;
  Duration _duration = const Duration(seconds: 6);
  Timer? _timer;
  DateTime? _startedAt;

  LooperController({required this.controller});

  LooperPose? get a => _a;
  LooperPose? get b => _b;
  Duration get duration => _duration;
  bool get isPlaying => _timer != null;
  bool get canLoop => _a != null && _b != null;

  LooperPlan? get plan {
    final a = _a;
    final b = _b;
    if (a == null || b == null) return null;
    return LooperPlan(a: a, b: b, duration: _duration);
  }

  void setAFromCurrent() {
    _a = LooperPose.fromView(controller.view);
    notifyListeners();
  }

  void setBFromCurrent() {
    _b = LooperPose.fromView(controller.view);
    notifyListeners();
  }

  void setDuration(Duration duration) {
    _duration = LooperPlan.cappedDuration(duration);
    notifyListeners();
  }

  void togglePreview() => isPlaying ? stop() : play();

  void play() {
    if (!canLoop || isPlaying) return;
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) => _tick());
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _startedAt = null;
    notifyListeners();
  }

  void _tick() {
    final plan = this.plan;
    final startedAt = _startedAt;
    if (plan == null || startedAt == null) return;

    final elapsed = DateTime.now().difference(startedAt).inMilliseconds;
    final durationMs = plan.duration.inMilliseconds;
    final phase = (elapsed % durationMs) / durationMs;
    final t = phase <= 0.5 ? phase * 2.0 : (1.0 - phase) * 2.0;
    controller.updateView(LooperPose.lerp(plan.a, plan.b, t).toView());
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
