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
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.rendererBackendTitle,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context)!.rendererBackendSubtitle,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                _backendModeTile(
                  context: context,
                  title: AppLocalizations.of(context)!.rendererBackendAuto,
                  subtitle: AppLocalizations.of(context)!.rendererBackendAutoSubtitle,
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
                  title: AppLocalizations.of(context)!.rendererBackendCpuOnly,
                  subtitle: AppLocalizations.of(context)!.rendererBackendCpuOnlySubtitle,
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
                  title: AppLocalizations.of(context)!.rendererBackendGpuOnly,
                  subtitle: AppLocalizations.of(context)!.rendererBackendGpuOnlySubtitle,
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
                    child: Text(AppLocalizations.of(context)!.actionClose),
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
        // ignore: deprecated_member_use
        trailing: Radio<RendererBackendMode>(
          value: value,
          // ignore: deprecated_member_use
          groupValue: groupValue,
          // ignore: deprecated_member_use
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
  /// Quick-save the current view + params as a named user preset (N4 Bookmarks).
  ///
  /// Auto-names the bookmark as "<Fractal> @ <zoom>×" so the user gets instant
  /// confirmation without having to type anything. The preset is retrievable via
  /// the existing PresetSheet (bookmark icon in the controls bar).
  Future<void> _saveBookmark(BuildContext context) async {
    final controller = _activeController(context);
    final presetStore = context.read<PresetStore>();
    final l10n = AppLocalizations.of(context)!;

    // Auto-name: "<ModuleName> @ <zoom>×"
    final zoom = controller.view.zoom;
    final zoomStr = zoom >= 1e6
        ? '${(zoom / 1e6).toStringAsFixed(1)}M×'
        : zoom >= 1e3
            ? '${(zoom / 1e3).toStringAsFixed(1)}k×'
            : '${zoom.toStringAsFixed(0)}×';
    final autoName =
        '${controller.module.displayName(l10n)} @ $zoomStr';

    final preset = FractalPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moduleId: controller.module.id,
      name: autoName,
      params: Map<String, Object>.from(controller.params),
      view: controller.view,
      createdAt: DateTime.now(),
    );

    try {
      await presetStore.saveUserPreset(preset);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Saved: $autoName',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _openPresets(context),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.presetSaveFailed(e.toString()))),
        );
      }
    }
  }

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
