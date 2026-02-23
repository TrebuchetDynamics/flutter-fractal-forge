part of 'fractal_viewer_screen.dart';

enum _ViewerMenuAction {
  saveLocation,
  historyBack,
  historyForward,
  openPresets,
  randomFractal,
  rendererMode,
  toggleRotation,
  toggleMinimap,
  openLogs,
  gpuDebug,
}

Future<void> _viewerOpenViewerQuickActions(
  _FractalViewerScreenState state,
  BuildContext context,
) async {
  final selected = await showModalBottomSheet<_ViewerMenuAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      final rotationLocked = state._activeController(context).rotationLocked;
      final historyProvider = context.read<HistoryProvider?>();
      final canGoBack = historyProvider?.canGoBack ?? false;
      final canGoForward = historyProvider?.canGoForward ?? false;
      final maxSheetHeight = MediaQuery.of(context).size.height * 0.72;
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.6)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.bookmark_add_rounded),
                    title: const Text('Save location'),
                    onTap: () => Navigator.of(context)
                        .pop(_ViewerMenuAction.saveLocation),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_rounded),
                    title: const Text('Open presets'),
                    onTap: () => Navigator.of(context)
                        .pop(_ViewerMenuAction.openPresets),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shuffle_rounded),
                    title: const Text('Random fractal'),
                    onTap: () => Navigator.of(context)
                        .pop(_ViewerMenuAction.randomFractal),
                  ),
                  if (canGoBack)
                    ListTile(
                      leading: const Icon(Icons.undo_rounded),
                      title: const Text('Back in view history'),
                      onTap: () => Navigator.of(context)
                          .pop(_ViewerMenuAction.historyBack),
                    ),
                  if (canGoForward)
                    ListTile(
                      leading: const Icon(Icons.redo_rounded),
                      title: const Text('Forward in view history'),
                      onTap: () => Navigator.of(context)
                          .pop(_ViewerMenuAction.historyForward),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.auto_mode_rounded),
                    title: const Text('Renderer mode'),
                    onTap: () => Navigator.of(context)
                        .pop(_ViewerMenuAction.rendererMode),
                  ),
                  ListTile(
                    leading: Icon(
                      rotationLocked
                          ? Icons.screen_lock_rotation_rounded
                          : Icons.screen_rotation_alt_rounded,
                    ),
                    title: Text(
                      rotationLocked ? 'Unlock rotation' : 'Lock rotation',
                    ),
                    onTap: () => Navigator.of(context)
                        .pop(_ViewerMenuAction.toggleRotation),
                  ),
                  ListTile(
                    leading: Icon(state._showMiniMap
                        ? Icons.map_rounded
                        : Icons.map_outlined),
                    title: Text(
                        state._showMiniMap ? 'Hide minimap' : 'Show minimap'),
                    onTap: () => Navigator.of(context)
                        .pop(_ViewerMenuAction.toggleMinimap),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_rounded),
                    title: const Text('View logs'),
                    onTap: () =>
                        Navigator.of(context).pop(_ViewerMenuAction.openLogs),
                  ),
                  if (kDebugMode)
                    ListTile(
                      leading: const Icon(Icons.bug_report_rounded),
                      title: const Text('GPU debug report'),
                      onTap: () =>
                          Navigator.of(context).pop(_ViewerMenuAction.gpuDebug),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  if (selected == null || !state.mounted) return;
  state._onViewerMenuSelected(context, selected);
}

void _viewerOnViewerMenuSelected(
  _FractalViewerScreenState state,
  BuildContext context,
  _ViewerMenuAction action,
) {
  switch (action) {
    case _ViewerMenuAction.saveLocation:
      state._saveBookmark(context);
      break;
    case _ViewerMenuAction.historyBack:
      state._goHistoryBack(context);
      break;
    case _ViewerMenuAction.historyForward:
      state._goHistoryForward(context);
      break;
    case _ViewerMenuAction.openPresets:
      state._openPresets(context);
      break;
    case _ViewerMenuAction.randomFractal:
      state._onRandomFractalFab(context);
      break;
    case _ViewerMenuAction.rendererMode:
      state._openBackendModePicker(context);
      break;
    case _ViewerMenuAction.toggleRotation:
      final controller = state._activeController(context);
      controller.toggleRotationLock();
      final locked = controller.rotationLocked;
      AccessibilityService.announce(
        locked ? 'Rotation locked' : 'Rotation unlocked',
      );
      HapticFeedback.selectionClick();
      break;
    case _ViewerMenuAction.toggleMinimap:
      state._toggleMiniMapVisibility();
      break;
    // Random fractal and AR mode are handled by dedicated viewer FABs.
    case _ViewerMenuAction.openLogs:
      final controller = context.read<FractalController>();
      state._log.logState('state', 'Snapshot at log open', {
        'module': controller.module.id,
        'panX': controller.view.pan.x,
        'panY': controller.view.pan.y,
        'zoom': controller.view.zoom,
        'iterations': controller.params['iterations'],
        'backend': state._backendDecision.backend.name,
        'backendReason': state._backendDecision.reasonToken,
      });
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LogViewerScreen()),
      );
      break;
    case _ViewerMenuAction.gpuDebug:
      state._shareGpuDebugReport(context);
      break;
  }
}

void _viewerApplyHistoryEntry(BuildContext context, HistoryEntry entry) {
  final controller = context.read<FractalController>();
  final registry = context.read<ModuleRegistry>();

  if (controller.module.id != entry.moduleId) {
    controller.selectModule(registry.byId(entry.moduleId), animate: false);
  }

  for (final paramEntry in entry.params.entries) {
    try {
      controller.updateParam(paramEntry.key, paramEntry.value);
    } catch (_) {
      // Ignore params not present in the selected module.
    }
  }

  controller.updateZoom(entry.view.zoom);
  controller.updatePan(entry.view.pan);
  controller.updateRotation(entry.view.rotation);
}

void _viewerGoHistoryBack(
  _FractalViewerScreenState state,
  BuildContext context,
) {
  final historyProvider = context.read<HistoryProvider?>();
  if (historyProvider == null) return;
  final entry = historyProvider.goBack();
  if (entry == null) return;
  state._applyHistoryEntry(context, entry);
  AccessibilityService.announce('Moved to previous view');
}

void _viewerGoHistoryForward(
  _FractalViewerScreenState state,
  BuildContext context,
) {
  final historyProvider = context.read<HistoryProvider?>();
  if (historyProvider == null) return;
  final entry = historyProvider.goForward();
  if (entry == null) return;
  state._applyHistoryEntry(context, entry);
  AccessibilityService.announce('Moved to next view');
}

void _viewerRecordHistory(BuildContext context) {
  final controller = context.read<FractalController>();
  final historyProvider = context.read<HistoryProvider?>();
  if (historyProvider == null) return;

  historyProvider.recordLocation(
    moduleId: controller.module.id,
    view: controller.view,
    params: controller.params,
  );
}
