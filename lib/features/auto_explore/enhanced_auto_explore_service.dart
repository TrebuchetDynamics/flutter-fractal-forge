import 'dart:async';
import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

/// Enhanced auto-zoom configuration with improved speed adaptation.
class EnhancedAutoExploreConfig {
  final double minZoom;
  final double maxZoom;
  final double cycleMaxMultiplier;
  final double maxLegSpanDecades;
  final double precisionHeadroom;
  final Duration travelDuration;
  final double maxDurationScale;
  final Duration minDuration;
  final double deepZoomSpeedBoost;
  final Curve easeCurve;

  const EnhancedAutoExploreConfig({
    this.minZoom = 0.2,
    this.maxZoom = 1e12,
    this.cycleMaxMultiplier = 120.0,
    this.maxLegSpanDecades = 3.2,
    this.precisionHeadroom = 0.92,
    this.travelDuration = const Duration(milliseconds: 6000),
    this.maxDurationScale = 3.0,
    this.minDuration = const Duration(milliseconds: 2000),
    this.deepZoomSpeedBoost = 1.5,
    this.easeCurve = Curves.easeInOutCubic,
  });
}

/// Enhanced auto navigation with adaptive speed and smoother motion.
class EnhancedAutoExploreService extends ChangeNotifier {
  final FractalController controller;
  final EnhancedAutoExploreConfig config;
  final DeepZoomPrecisionPolicy _precisionPolicy =
      const DeepZoomPrecisionPolicy();

  bool _isExploring = false;
  bool _isPaused = false;
  bool _pausedByUserCorrection = false;
  bool _isUserInteracting = false;
  double _speed = 1.0;

  Timer? _timer;

  double? _cycleBaseZoom;
  double? _lastCorrectionZoom;
  double? _interactionStartZoom;
  bool _zoomingIn = true;

  EnhancedAutoExploreService({
    required this.controller,
    this.config = const EnhancedAutoExploreConfig(),
  });

  bool get isExploring => _isExploring;
  bool get isPaused => _isPaused;
  bool get pausedByUserCorrection => _pausedByUserCorrection;

  double get speed => _speed;
  set speed(double v) {
    _speed = v.clamp(0.5, 3.0);
    notifyListeners();
  }

  void start() {
    if (_isExploring && !_isPaused) return;

    _isExploring = true;
    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _cycleBaseZoom = _clampZoom(controller.view.zoom);
    _lastCorrectionZoom = _cycleBaseZoom;
    _zoomingIn = true;

    _scheduleNext();
    notifyListeners();
  }

  void pause() {
    if (!_isExploring) return;
    _isPaused = true;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _timer?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!_isExploring) {
      start();
      return;
    }
    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _scheduleNext();
    notifyListeners();
  }

  void onUserInteractionStart() {
    if (!_isExploring || _isPaused) return;
    if (_isUserInteracting) return;
    _isUserInteracting = true;
    _pausedByUserCorrection = true;
    _interactionStartZoom = _clampZoom(controller.view.zoom);
    _timer?.cancel();
    notifyListeners();
  }

  void onUserInteractionEnd() {
    if (!_isExploring) return;
    final referenceZoom = _interactionStartZoom;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _adoptUserViewAndContinue(referenceZoom: referenceZoom);
  }

  void onUserCorrection() {
    if (!_isExploring || _isPaused) return;
    _adoptUserViewAndContinue();
  }

  void _adoptUserViewAndContinue({double? referenceZoom}) {
    if (!_isExploring) return;
    final currentZoom = _clampZoom(controller.view.zoom);
    final previousZoom =
        _clampZoom(referenceZoom ?? _lastCorrectionZoom ?? currentZoom);

    const epsilon = 1e-4;
    if (currentZoom > previousZoom * (1.0 + epsilon)) {
      _zoomingIn = true;
    } else if (currentZoom < previousZoom * (1.0 - epsilon)) {
      _zoomingIn = false;
    }

    _cycleBaseZoom = currentZoom;
    _lastCorrectionZoom = currentZoom;
    _pausedByUserCorrection = false;
    _timer?.cancel();
    if (!_isPaused && !_isUserInteracting) {
      _scheduleNext();
    }
    notifyListeners();
  }

  void toggle() {
    if (!_isExploring) return start();
    if (_isPaused) return resume();
    return pause();
  }

  void stop() {
    _isExploring = false;
    _isPaused = false;
    _pausedByUserCorrection = false;
    _isUserInteracting = false;
    _interactionStartZoom = null;
    _timer?.cancel();
    _cycleBaseZoom = null;
    _lastCorrectionZoom = null;
    _zoomingIn = true;
    notifyListeners();
  }

  double _clampZoom(double z) => z.clamp(config.minZoom, config.maxZoom);

  double _smartHardMaxZoom() {
    final moduleThreshold = _precisionPolicy.thresholdFor(controller.module.id);
    return (moduleThreshold * config.precisionHeadroom)
        .clamp(config.minZoom, config.maxZoom);
  }

  double _computePeakZoom(double baseZoom) {
    final hardMax = _smartHardMaxZoom();
    final minPeak = _clampZoom(baseZoom * 1.25);
    final configuredPeak = _clampZoom(baseZoom * config.cycleMaxMultiplier);
    final maxSpanRatio = pow(10.0, config.maxLegSpanDecades).toDouble();
    final spanLimitedPeak = _clampZoom(baseZoom * maxSpanRatio);
    final desiredPeak = min(configuredPeak, spanLimitedPeak);
    return max(minPeak, min(desiredPeak, hardMax));
  }

  double _computeFloorZoom(double baseZoom) {
    final contextualFloor = baseZoom / config.cycleMaxMultiplier;
    return _clampZoom(max(config.minZoom, contextualFloor));
  }

  double _nextTargetZoom() {
    final current = _clampZoom(controller.view.zoom);
    _cycleBaseZoom ??= current;
    final baseZoom = _clampZoom(_cycleBaseZoom!);
    final peakZoom = _computePeakZoom(baseZoom);
    final floorZoom = _computeFloorZoom(baseZoom);
    if ((peakZoom - floorZoom).abs() < 1e-9) return baseZoom;
    return _zoomingIn ? peakZoom : floorZoom;
  }

  void _scheduleNext() {
    _timer?.cancel();
    if (!_isExploring || _isPaused || _isUserInteracting) return;

    _timer = Timer(Duration.zero, () async {
      if (!_isExploring || _isPaused || _isUserInteracting) return;
      final targetZoom = _nextTargetZoom();
      final reachedTarget = await _animateZoomTo(targetZoom);
      if (!_isExploring || _isPaused || _isUserInteracting) return;
      if (reachedTarget) {
        _zoomingIn = !_zoomingIn;
      }
      _scheduleNext();
    });
  }

  Duration _durationForZoomLeg(double startZoom, double endZoom) {
    final safeStart = max(1e-9, startZoom);
    final safeEnd = max(1e-9, endZoom);
    final ratio = max(safeStart, safeEnd) / min(safeStart, safeEnd);
    final decades = ratio <= 1.0 ? 0.0 : (log(ratio) / ln10);
    final normalized = (decades / 1.6).clamp(0.0, 1.0);
    final scale = 1.0 + normalized * (config.maxDurationScale - 1.0);

    // Apply deep zoom speed boost
    final currentZoom = controller.view.zoom;
    double zoomBoost = 1.0;
    if (currentZoom > 1e6) {
      zoomBoost = config.deepZoomSpeedBoost;
    }

    final ms = max(config.minDuration.inMilliseconds,
        (config.travelDuration.inMilliseconds * scale / zoomBoost).round());
    return _scaledDuration(Duration(milliseconds: ms));
  }

  Future<bool> _animateZoomTo(double targetZoom) async {
    _timer?.cancel();
    final startZoom = _clampZoom(controller.view.zoom);
    final endZoom = _clampZoom(targetZoom);
    final duration = _durationForZoomLeg(startZoom, endZoom);

    // Adaptive frame duration: faster at deep zoom
    final currentZoom = controller.view.zoom;
    int frameMicros = 16000; // 16ms = 60fps
    if (currentZoom > 1e6) {
      frameMicros = 11000; // ~90fps at deep zoom
    } else if (currentZoom > 1e4) {
      frameMicros = 13000; // ~75fps at medium zoom
    }
    final frame = Duration(microseconds: frameMicros);

    final total =
        max(1, (duration.inMilliseconds * 1000 / frame.inMicroseconds).round());
    var step = 0;

    final completer = Completer<bool>();

    _timer = Timer.periodic(frame, (timer) {
      if (!_isExploring || _isPaused || _isUserInteracting) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete(false);
        return;
      }

      step++;
      final raw = (step / total).clamp(0.0, 1.0);
      final eased = config.easeCurve.transform(raw);

      controller.updateZoom(_interpolateZoom(startZoom, endZoom, eased));
      _lastCorrectionZoom = _clampZoom(controller.view.zoom);

      if (raw >= 1.0) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    return completer.future;
  }

  double _interpolateZoom(double start, double end, double t) {
    final safeStart = max(1e-9, start);
    final safeEnd = max(1e-9, end);
    return safeStart * pow(safeEnd / safeStart, t).toDouble();
  }

  Duration _scaledDuration(Duration d) {
    final millis = (d.inMilliseconds / _speed).round();
    return Duration(milliseconds: max(1, millis));
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
