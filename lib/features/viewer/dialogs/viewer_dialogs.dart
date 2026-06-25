part of '../fractal_viewer_screen.dart';

/// Mixin that handles modal sheet / dialog launchers.
///
/// Apply to `State<FractalViewerScreen>` with `_ExportActionsMixin` so the
/// dialog launchers can reuse shared viewer state and services.
mixin _ViewerDialogsMixin on State<FractalViewerScreen>, _ExportActionsMixin {
  Future<T?> _showViewerBottomSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  void _openControls(BuildContext context) {
    _log.info('action', 'Open controls');
    final controller = _activeController(context);
    _showViewerBottomSheet<void>(
      context,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const FractalControlsSheet(),
      ),
    );
  }

  void _openLooper(BuildContext context) {
    _log.info('action', 'Open looper');
    final looper = _looperController;
    if (looper == null) return;
    _showViewerBottomSheet<void>(
      context,
      builder: (_) => LooperSheet(
        controller: looper,
        isExporting: _exporting,
        onExportGif: () => _exportLooperGif(context),
      ),
    );
  }

  void _openPresets(BuildContext context) {
    _log.info('action', 'Open presets');
    final controller = _activeController(context);
    _showViewerBottomSheet<void>(
      context,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: PresetSheet(
          onBatchExport: () => _openBatchExport(context),
        ),
      ),
    );
  }

  void _openBatchExport(BuildContext context) {
    final boundaryKey = _activeBoundaryKey();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _activeController(context)),
          Provider.value(value: context.read<PresetStore>()),
        ],
        child: BatchExportDialog(boundaryKey: boundaryKey),
      ),
    );
  }
}
