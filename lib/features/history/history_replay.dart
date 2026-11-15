import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/core/models/history/history_location.dart';

/// Replayable controller mutation plan for one history entry.
///
/// A history entry is a complete fractal state: module id, parameters, and
/// view. Controllers that expose `loadState(moduleId, params, view)` can apply
/// that complete state in one step so module-specific params are normalized
/// against the recorded module. Older controller-like test doubles without
/// `loadState` keep the legacy incremental replay sequence.
final class HistoryControllerReplayPlan {
  HistoryControllerReplayPlan({
    required this.moduleId,
    required FractalViewState view,
    required Map<String, Object> params,
  })  : view = snapshotHistoryView(view),
        params = snapshotHistoryParams(params);

  factory HistoryControllerReplayPlan.fromEntry(HistoryEntry entry) {
    return HistoryControllerReplayPlan(
      moduleId: entry.moduleId,
      view: entry.view,
      params: entry.params,
    );
  }

  final String moduleId;
  final FractalViewState view;
  final Map<String, Object> params;

  Future<bool> applyTo(
    Object controller, {
    void Function()? onCommitted,
    bool Function()? shouldCommit,
  }) {
    if (controller is FractalController) {
      return controller.loadState(
        moduleId: moduleId,
        params: params,
        view: view,
        onCommitted: onCommitted,
        shouldCommit: shouldCommit,
      );
    }
    // Only legacy structural test doubles use incremental replay. Do not probe
    // them for optional callbacks: real controllers own complete-state commits.
    if (!(shouldCommit?.call() ?? true)) return Future.value(false);
    _applyIncrementalState(controller);
    onCommitted?.call();
    return Future.value(true);
  }

  void _applyIncrementalState(Object controller) {
    final target = controller as dynamic;

    for (final paramEntry in params.entries) {
      try {
        target.updateParam(paramEntry.key, paramEntry.value);
      } catch (_) {
        // Parameter may not exist in current module.
      }
    }

    try {
      target.updateView(view);
    } on NoSuchMethodError {
      target.updateZoom(view.zoom);
      target.updatePan(view.pan);
      target.updateRotation(view.rotation);
    }
  }
}

/// Applies a complete history entry to a controller-like object.
Future<bool> applyHistoryEntryToController(
  HistoryEntry entry,
  Object controller, {
  void Function()? onCommitted,
  bool Function()? shouldCommit,
}) =>
    HistoryControllerReplayPlan.fromEntry(entry).applyTo(
      controller,
      onCommitted: onCommitted,
      shouldCommit: shouldCommit,
    );
