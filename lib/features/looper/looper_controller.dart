import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/controllers/params/fractal_param_value_normalizer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'looper_camera_sampler.dart';
import 'package:vector_math/vector_math_64.dart';

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
    final eased =
        clamped * clamped * clamped * (clamped * (clamped * 6 - 15) + 10);
    double mix(double start, double end, double amount) =>
        start + (end - start) * amount;
    return LooperPose(
      x: mix(a.x, b.x, eased),
      y: mix(a.y, b.y, eased),
      z: math.exp(mix(math.log(a.z), math.log(b.z), eased)),
      rotationX: mix(a.rotationX, b.rotationX, clamped),
      rotationY: mix(a.rotationY, b.rotationY, clamped),
      rotationZ: mix(a.rotationZ, b.rotationZ, clamped),
    );
  }
}

@immutable
class LooperPoint {
  final FractalViewState view;
  final Map<String, Object> params;

  LooperPoint({
    required this.view,
    required Map<String, Object> params,
  }) : params = Map.unmodifiable(params);

  factory LooperPoint.fromController(FractalController controller) {
    return LooperPoint(view: controller.view, params: controller.params);
  }

  LooperPose get pose => LooperPose.fromView(view);

  static LooperPoint lerp(
    FractalModule module,
    LooperPoint a,
    LooperPoint b,
    double t,
  ) {
    final clamped = t.clamp(0.0, 1.0);
    return LooperPoint(
      view: LooperPose.lerp(a.pose, b.pose, clamped).toView(),
      params: {
        for (final schema in module.parameters)
          schema.id: _lerpParam(
            schema,
            a.params[schema.id] ?? schema.defaultValue,
            b.params[schema.id] ?? schema.defaultValue,
            clamped,
          ),
      },
    );
  }

  static Object _lerpParam(
    FractalParameter schema,
    Object start,
    Object end,
    double t,
  ) {
    if (schema.type == FractalParamType.float && start is num && end is num) {
      return normalizeFractalParamValue(
        schema,
        start.toDouble() + (end.toDouble() - start.toDouble()) * t,
      );
    }
    if (schema.type == FractalParamType.integer && start is num && end is num) {
      return normalizeFractalParamValue(
        schema,
        (start.toDouble() + (end.toDouble() - start.toDouble()) * t).round(),
      );
    }
    if (schema.type == FractalParamType.enumeration) {
      return _lerpEnumParam(schema, start, end, t);
    }
    if (schema.type == FractalParamType.boolean) {
      return t < 0.5 ? start : end;
    }
    return t < 0.5 ? start : end;
  }

  static Object _lerpEnumParam(
    FractalParameter schema,
    Object start,
    Object end,
    double t,
  ) {
    if (start is num && end is num) {
      final mixed = start.toDouble() + (end.toDouble() - start.toDouble()) * t;
      Object best = schema.defaultValue;
      var bestDistance = double.infinity;
      for (final option in schema.options) {
        final value = option.value;
        if (value is! num) continue;
        final distance = (value.toDouble() - mixed).abs();
        if (distance < bestDistance) {
          best = value;
          bestDistance = distance;
        }
      }
      return normalizeFractalParamValue(schema, best);
    }
    return normalizeFractalParamValue(schema, t < 0.5 ? start : end);
  }
}

class LooperPlan {
  static const Duration maxDuration = Duration(seconds: 15);
  static const Duration minDuration = Duration(seconds: 1);
  static const int exportFps = 8;

  final FractalModule module;
  final List<LooperPoint> points;
  final Duration duration;

  LooperPlan({
    required this.module,
    required List<LooperPoint> points,
    required Duration duration,
  })  : points = List.unmodifiable(points),
        duration = cappedDuration(duration);

  LooperPose get a => points.first.pose;
  LooperPose get b => points[1].pose;

  int get frameCount =>
      (duration.inMilliseconds * exportFps / 1000).round().clamp(2, 120);

  LooperPose poseAtFrame(int frameIndex) => stateAtFrame(frameIndex).pose;

  LooperPoint stateAtFrame(int frameIndex) {
    final count = frameCount;
    if (count <= 1) return points.first;
    // Sample one complete period on [0, 1). Playback supplies the wrap from the
    // last sample back to A; storing A again as the final sample creates a
    // duplicate-frame pause and skips the true final motion sample.
    final clampedIndex = frameIndex.clamp(0, count - 1);
    return stateAtPhase(clampedIndex / count);
  }

  LooperPoint stateAtPhase(double phase) {
    if (points.length < 2) return points.first;
    final wrapped = phase % 1.0;
    final scaled = wrapped * points.length;
    final index = scaled.floor().clamp(0, points.length - 1);
    final next = (index + 1) % points.length;
    return LooperPoint.lerp(
        module, points[index], points[next], scaled - index);
  }

  static Duration cappedDuration(Duration value) {
    if (value < minDuration) return minDuration;
    if (value > maxDuration) return maxDuration;
    return value;
  }
}

class LooperController extends ChangeNotifier {
  final FractalController controller;
  final bool Function()? exportIsBusy;
  final List<LooperPoint> _points = [];
  Duration _duration = const Duration(seconds: 6);
  Timer? _timer;
  late String _moduleId;

  LooperController({required this.controller, this.exportIsBusy}) {
    _moduleId = controller.module.id;
    controller.addListener(_resetIfModuleChanged);
  }

  List<LooperPoint> get points => List.unmodifiable(_points);
  LooperPose? get a => _points.isEmpty ? null : _points[0].pose;
  LooperPose? get b => _points.length < 2 ? null : _points[1].pose;
  Duration get duration => _duration;
  bool get isPlaying => _timer != null;
  bool get canLoop => _points.length >= 2;

  LooperPlan? get plan {
    if (!canLoop) return null;
    return LooperPlan(
      module: controller.module,
      points: _points,
      duration: _duration,
    );
  }

  static String labelForIndex(int index) {
    if (index >= 0 && index < 26) return String.fromCharCode(65 + index);
    return '${index + 1}';
  }

  void addPointFromCurrent() {
    _points.add(LooperPoint.fromController(controller));
    notifyListeners();
  }

  bool _isExporting = false;
  bool _disposed = false;

  bool get hasTrajectoryPoints =>
      controller.view.trajectory != null ||
      _points.any((point) => point.view.trajectory != null);

  bool get canRandomizePoints =>
      !_isExporting && !(exportIsBusy?.call() ?? false) && !hasTrajectoryPoints;

  void setExporting(bool value) {
    if (_disposed || _isExporting == value) return;
    _isExporting = value;
    notifyListeners();
  }

  bool randomizePoint(int index, {math.Random? random}) {
    // Only A/B may be created this way; optional points require explicit Add.
    if (!canRandomizePoints ||
        index < 0 ||
        index > _points.length ||
        (index == _points.length && index > 1)) return false;
    final anchor = index < _points.length
        ? _points[index]
        : _points.isEmpty
            ? LooperPoint.fromController(controller)
            : _points.last;
    return _commitRandomPoint(index, anchor, random ?? math.Random());
  }

  bool addRandomPoint({math.Random? random}) {
    if (!canRandomizePoints || !canLoop) return false;
    return _commitRandomPoint(
        _points.length, _points.last, random ?? math.Random());
  }

  bool _commitRandomPoint(int index, LooperPoint anchor, math.Random random) {
    final sampled = sampleLooperCamera(
        module: controller.module, anchor: anchor.view, random: random);
    if (sampled == null) return false;
    final before = anchor.pose;
    final after = LooperPose.fromView(sampled);
    if (before.x == after.x &&
        before.y == after.y &&
        before.z == after.z &&
        before.rotationX == after.rotationX &&
        before.rotationY == after.rotationY &&
        before.rotationZ == after.rotationZ) return false;

    // Commit once. Rejected/no-change samples never stop an active preview.
    _timer?.cancel();
    _timer = null;
    final point = LooperPoint(view: sampled, params: anchor.params);
    if (index == _points.length) {
      _points.add(point);
    } else {
      _points[index] = point;
    }
    notifyListeners();
    return true;
  }

  void setPointFromCurrent(int index) {
    if (index < 0 || index > _points.length) return;
    final point = LooperPoint.fromController(controller);
    if (index == _points.length) {
      _points.add(point);
    } else {
      _points[index] = point;
    }
    notifyListeners();
  }

  void removePoint(int index) {
    if (index < 0 || index >= _points.length) return;
    _points.removeAt(index);
    notifyListeners();
  }

  void setAFromCurrent() => setPointFromCurrent(0);

  void setBFromCurrent() => setPointFromCurrent(1);

  void setDuration(Duration duration) {
    _duration = LooperPlan.cappedDuration(duration);
    notifyListeners();
  }

  void togglePreview() => isPlaying ? stop() : play();

  void play() {
    if (!canLoop || isPlaying) return;
    _timer = Timer.periodic(const Duration(milliseconds: 33), _tick);
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void _resetIfModuleChanged() {
    final moduleId = controller.module.id;
    if (_moduleId == moduleId) return;
    _moduleId = moduleId;
    _points.clear();
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void _tick(Timer timer) {
    final plan = this.plan;
    if (plan == null) return;

    // Timer.tick includes missed intervals, without coupling preview to the
    // adjustable wall clock. Preview and export sample the same stored plan.
    final elapsed = timer.tick * 33;
    final durationMs = plan.duration.inMilliseconds;
    final point = plan.stateAtPhase((elapsed % durationMs) / durationMs);
    controller.loadState(
      params: point.params,
      view: point.view,
      transparentBackground: controller.transparentBackground,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    controller.removeListener(_resetIfModuleChanged);
    stop();
    super.dispose();
  }
}
