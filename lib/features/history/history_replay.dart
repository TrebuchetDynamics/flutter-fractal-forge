import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/features/history/history_location.dart';

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

  void applyTo(Object controller) {
    if (_tryApplyCompleteState(controller)) return;
    _applyIncrementalState(controller);
  }

  bool _tryApplyCompleteState(Object controller) {
    final Function loadState;
    try {
      loadState = (controller as dynamic).loadState as Function;
    } on NoSuchMethodError {
      return false;
    }

    Function.apply(loadState, const [], {
      #moduleId: moduleId,
      #params: params,
      #view: view,
    });
    return true;
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

    target.updateZoom(view.zoom);
    target.updatePan(view.pan);
    target.updateRotation(view.rotation);
  }
}

/// Applies a complete history entry to a controller-like object.
void applyHistoryEntryToController(HistoryEntry entry, Object controller) {
  HistoryControllerReplayPlan.fromEntry(entry).applyTo(controller);
}
