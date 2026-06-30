import 'dart:math' as math;

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';

/// Tracks session-level exploration metrics (zoom distance, time, modules).
///
/// All accumulation logic lives here so the computation is testable without a
/// widget tree. The caller is responsible for lifecycle: call [attach] when the
/// controller is connected, [onControllerChanged] on every controller change
/// notification, and [end] in dispose.
class ViewerSessionTracker {
  final ExplorationStatsService? _statsService;

  DateTime? _sessionStart;
  double? _lastZoom;
  String? _lastModuleId;

  ViewerSessionTracker({ExplorationStatsService? statsService})
      : _statsService = statsService;

  /// The module id seen by the most recent [attach] or [onControllerChanged].
  /// Null until [attach] is first called.
  String? get lastModuleId => _lastModuleId;

  /// Called when the active controller is set (or replaced).
  /// Seeds the zoom and module baselines; starts the session clock once.
  void attach(FractalController controller) {
    _sessionStart ??= DateTime.now();
    _lastZoom = controller.view.zoom;
    _lastModuleId = controller.module.id;
    _statsService?.recordFractalExplored(controller.module.id);
  }

  /// Called on every controller change notification.
  /// Accumulates zoom distance and records newly-explored modules.
  void onControllerChanged(FractalController controller) {
    final prevZoom = _lastZoom;
    final currentZoom = controller.view.zoom;
    if (prevZoom != null &&
        prevZoom > 0 &&
        currentZoom > 0 &&
        prevZoom != currentZoom) {
      _statsService
          ?.addZoomDistance((math.log(currentZoom / prevZoom)).abs());
    }
    _lastZoom = currentZoom;

    final currentId = controller.module.id;
    if (_lastModuleId != currentId) {
      _lastModuleId = currentId;
      _statsService?.recordFractalExplored(currentId);
    }
  }

  /// Records the elapsed session time. Call once from dispose.
  void end() {
    final start = _sessionStart;
    if (start != null) {
      _statsService?.addExploreTime(DateTime.now().difference(start));
    }
  }
}
