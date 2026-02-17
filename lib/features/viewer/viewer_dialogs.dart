part of 'fractal_viewer_screen.dart';

/// Mixin that handles modal sheet / dialog launchers.
///
/// Depends on [_ExportActionsMixin] for wallpaper and video export delegates.
/// Apply to `State<FractalViewerScreen>` with `_ExportActionsMixin`.
mixin _ViewerDialogsMixin on State<FractalViewerScreen>, _ExportActionsMixin {
  void _openBackendModePicker(BuildContext context) {
    final settings = context.read<RendererSettingsService>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final mode = settings.backendMode;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renderer Backend',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose how fractals are rendered. Auto is recommended.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                _backendModeTile(
                  context: context,
                  title: 'Auto',
                  subtitle:
                      'Use GPU when healthy; fall back to CPU when needed.',
                  value: RendererBackendMode.auto,
                  groupValue: mode,
                  onChanged: (v) async {
                    await settings.setBackendMode(v);
                    if (context.mounted) Navigator.of(context).pop();
                    AccessibilityService.announce('Renderer backend: Auto');
                  },
                ),
                _backendModeTile(
                  context: context,
                  title: 'CPU only (stable)',
                  subtitle: 'Always use the stable CPU renderer.',
                  value: RendererBackendMode.cpuOnly,
                  groupValue: mode,
                  onChanged: (v) async {
                    await settings.setBackendMode(v);
                    if (context.mounted) Navigator.of(context).pop();
                    AccessibilityService.announce('Renderer backend: CPU only');
                  },
                ),
                _backendModeTile(
                  context: context,
                  title: 'GPU only (debug)',
                  subtitle:
                      'Always try GPU rendering. May show black/invalid output on some devices.',
                  value: RendererBackendMode.gpuOnly,
                  groupValue: mode,
                  onChanged: (v) async {
                    await settings.setBackendMode(v);
                    if (context.mounted) Navigator.of(context).pop();
                    AccessibilityService.announce('Renderer backend: GPU only');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _backendModeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required RendererBackendMode value,
    required RendererBackendMode groupValue,
    required ValueChanged<RendererBackendMode> onChanged,
  }) {
    final selected = value == groupValue;
    return Semantics(
      container: true,
      label: title,
      hint: subtitle,
      selected: selected,
      button: true,
      onTap: () => onChanged(value),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: AppTypography.titleMedium),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing: Radio<RendererBackendMode>(
          value: value,
          groupValue: groupValue,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
        onTap: () => onChanged(value),
      ),
    );
  }

  void _openControls(BuildContext context) {
    _log.info('action', 'Open controls');
    final controller = _activeController(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const FractalControlsSheet(),
      ),
    );
  }

  void _openPresets(BuildContext context) {
    _log.info('action', 'Open presets');
    final controller = _activeController(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  // ignore: unused_element
  void _openHistory(BuildContext context) {
    final controller = context.read<FractalController>();
    final historyProvider = context.read<HistoryProvider?>();
    if (historyProvider == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider.value(value: historyProvider),
        ],
        child: const HistorySheet(),
      ),
    );
  }

  void _openAutoExploreSettings(BuildContext context) {
    if (_autoExploreService == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider<AutoExploreService>.value(
        value: _autoExploreService!,
        child: const AutoExploreSettingsSheet(),
      ),
    );
  }

  // ignore: unused_element
  void _openWallpaper(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WallpaperOptionsSheet(
        initial: const WallpaperOptions(),
        onApply: (options) => _applyWallpaper(context, options),
      ),
    );
  }

  // ignore: unused_element
  void _openVideoExport(BuildContext context) {
    final controller = context.read<FractalController>();

    final availableParams = <String>[];
    final paramRanges = <String, (double, double)>{};

    for (final param in controller.module.parameters) {
      if (param.type.name == 'float' || param.type.name == 'integer') {
        availableParams.add(param.id);
        paramRanges[param.id] = (param.min, param.max);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoExportSheet(
        initialOptions: const VideoExportOptions(),
        fractalType: controller.module.id,
        availableParameters: availableParams,
        parameterRanges: paramRanges,
        onExport: (options) => _performVideoExport(context, options),
      ),
    );
  }
}
