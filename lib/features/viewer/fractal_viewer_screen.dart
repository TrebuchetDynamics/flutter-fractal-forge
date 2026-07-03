import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:flutter_fractals/features/viewer/actions/text_overlay_controller.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_music_coordinator.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_session_tracker.dart';
import 'package:vector_math/vector_math.dart' show Vector2;
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/diagnostics/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/wallpaper_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/platform/haptic_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/renderer/policy/render_plan.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/debug/shader_lab_screen.dart';
import 'package:flutter_fractals/features/export/batch_export_dialog.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';
import 'package:flutter_fractals/features/looper/looper_sheet.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/renderer/policy/backend_policy.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_family.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_feedback.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/features/viewer/rendering/compare_renderer.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_scan_overlay.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';
import 'package:flutter_fractals/features/viewer/overlays/auto_pilot_alignment_overlay.dart';
import 'package:flutter_fractals/features/viewer/diagnostics/gpu_health_probe.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

part 'diagnostics/viewer_gpu_health.dart';
part 'diagnostics/viewer_debug_report.dart';
part 'dialogs/viewer_dialogs.dart';
part 'export/viewer_export_actions.dart';
part 'navigation/viewer_interactions.dart';
part 'navigation/viewer_history.dart';
part 'overlays/viewer_hud.dart';

class FractalViewerScreen extends StatefulWidget {
  /// Chrome-free capture mode for marketing/launch stills.
  ///
  /// When true the viewer opens in fullscreen-unobtrusive mode (no chips,
  /// banners, or FAB column) AND suppresses the lone fullscreen-exit FAB, so the
  /// rendered canvas fills the frame with zero overlays. Only set this from the
  /// Playwright capture route — never from normal navigation.
  final bool captureMode;

  /// Catalog family that opened this viewer.
  ///
  /// Core fractals keep the existing viewer chrome. Performance Fractals use
  /// this seam to avoid retrofitting instrument controls onto classic modules.
  final CatalogFamily catalogFamily;

  const FractalViewerScreen({
    Key? key,
    this.captureMode = false,
    this.catalogFamily = CatalogFamily.core,
  }) : super(key: key);

  @override
  State<FractalViewerScreen> createState() => _FractalViewerScreenState();
}

class _FractalViewerScreenState extends State<FractalViewerScreen>
    with
        WidgetsBindingObserver,
        TickerProviderStateMixin,
        _GpuHealthMixin,
        _DebugReportMixin,
        _ExportActionsMixin,
        _ViewerDialogsMixin {
  @override
  final GlobalKey _fractalKeyA = GlobalKey();
  final GlobalKey _fractalKeyB = GlobalKey();
  @override
  final ExportService _exportService = const ExportService();
  final ViewerEffectsController _viewerEffects = ViewerEffectsController();

  // Compare mode state
  @override
  final bool _compareMode = false;
  final bool _compareSliderMode =
      false; // false: side-by-side, true: sliding divider
  double _compareDivider = 0.5; // 0..1 (only used for slider mode)
  int _activePane = 0; // 0: A (primary/provider), 1: B (secondary)
  FractalController? _compareController;
  DebugRunnerService? _debugRunner;
  late AnimationController _fabController;
  late AnimationController _musicScanController;
  late ViewerMusicCoordinator _musicCoordinator;

  // Visual simplification state
  bool _fullscreenUnobtrusive = false;
  bool _showControlsHud = false;
  final TextOverlayController _textOverlay = TextOverlayController();

  // History tracking
  FractalController? _lastController;

  ViewerSessionTracker? _sessionTracker;

  // Auto-explore service
  @override
  AutoExploreService? _autoExploreService;
  @override
  LooperController? _looperController;

  String? _lastBackendDecisionLogged;
  Timer? _backendDebounceTimer;
  bool _appVisible = true;

  bool get _liveRenderingEnabled => _appVisible && !_freezeFrameForExport;

  bool get _usesCoreViewerChrome => widget.catalogFamily == CatalogFamily.core;

  bool get _showCoreViewerChrome =>
      _usesCoreViewerChrome && !_fullscreenUnobtrusive;

  @override
  final AppLogger _log = AppLogger.instance;
  final FocusNode _keyboardFocusNode =
      FocusNode(debugLabel: 'fractal-viewer-keyboard-focus');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.captureMode) {
      // Open chrome-free: hide chips/banners/FAB column for clean stills.
      _fullscreenUnobtrusive = true;
    }
    _fabController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    )..forward();
    _musicScanController = AnimationController(
      duration: fractalMusicLoopDuration,
      vsync: this,
    );
    _musicCoordinator = ViewerMusicCoordinator(
      effects: _viewerEffects,
      captureFrame: _captureFractalMusicScanFrame,
      syncAnimation: (enabled) {
        if (!mounted) return;
        _syncFractalMusicScanAnimation(enabled);
      },
      notifyState: () {
        if (!mounted) return;
        setState(() {});
      },
    );
    _loadTextOverlay();
    _log.info('lifecycle', 'FractalViewerScreen initState');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final visible = state == AppLifecycleState.resumed;
    if (_appVisible == visible) return;
    setState(() {
      _appVisible = visible;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode && _debugRunner == null) {
      _debugRunner = DebugRunnerService(
        controller: context.read<FractalController>(),
        registry: context.read<ModuleRegistry>(),
      );
    }

    _sessionTracker ??= ViewerSessionTracker(
      statsService: context.read<ExplorationStatsService?>(),
    );

    // Set up history + stats tracking
    final controller = context.read<FractalController>();
    if (_lastController != controller) {
      _lastController?.removeListener(_onControllerChanged);
      _lastController = controller;

      _sessionTracker!.attach(controller);

      controller.addListener(_onControllerChanged);
      // Record initial state
      _recordHistory(context);

      _gpuProbe.resetHealth();
      _refreshPrecisionDecision(controller);
      _refreshBackendDecision();
      _scheduleGpuHealthCheck();
      _detectEmulatorProfile();

      // Initialize auto-explore service
      _autoExploreService?.dispose();
      _autoExploreService = AutoExploreService(controller: controller);
      _looperController?.dispose();
      _looperController = LooperController(controller: controller);
    }
  }

  void _onAutoExploreUserCorrection() {
    _autoExploreService?.onUserCorrection();
  }

  void _onAutoExploreUserInteractionStart() {
    _autoExploreService?.onUserInteractionStart();
  }

  void _onAutoExploreUserInteractionEnd() {
    _autoExploreService?.onUserInteractionEnd();
  }

  void _onControllerChanged() {
    if (!mounted) return;

    final controller = _lastController!;
    final prevModuleId = _sessionTracker?.lastModuleId;
    final moduleChanged =
        prevModuleId != null && prevModuleId != controller.module.id;

    if (moduleChanged) {
      _gpuProbe.resetHealth();
      _scheduleGpuHealthCheck();
    }

    // Deep-zoom precision indicator — uses same decision as backend routing
    // so the UI badge and renderer path stay in sync.
    _refreshPrecisionDecision(controller);
    _refreshBackendDecision();

    // Record view/config changes into history
    _recordHistory(context);
    _musicCoordinator.scheduleRescan(controller);

    if (moduleChanged) {
      _log.logState('action', 'Module changed', {
        'from': prevModuleId,
        'to': controller.module.id,
      });
    }

    _sessionTracker?.onControllerChanged(controller);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gpuHealthTimer?.cancel();
    _backendDebounceTimer?.cancel();
    _musicCoordinator.dispose();
    _lastController?.removeListener(_onControllerChanged);
    _sessionTracker?.end();

    _lastGpuSnapshot?.dispose();
    _fabController.dispose();
    _musicScanController.dispose();
    _debugRunner?.dispose();
    _autoExploreService?.dispose();
    _looperController?.dispose();
    _compareController?.dispose();
    _viewerEffects.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTextOverlay() async {
    await _textOverlay.load();
    if (mounted) setState(() {});
  }

  void _toggleControlsHud() {
    setState(() {
      _showControlsHud = !_showControlsHud;
    });
    if (_showControlsHud) {
      HapticService.medium();
    }
  }

  Future<void> _toggleTextOverlay() async {
    if (_textOverlay.needsEditBeforeToggle) {
      await _editTextOverlay();
      return;
    }
    setState(() => _textOverlay.toggle());
    await _textOverlay.save();
  }

  Future<void> _editTextOverlay() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _textOverlay.text);
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: AppBottomSheet(
          maxHeightFactor: 0.52,
          children: [
            AppBottomSheetHeader(
              icon: Icons.format_quote_rounded,
              title: l10n.textOverlayTitle,
              subtitle: 'Add a short caption over the rendered image.',
              onClose: () => Navigator.of(sheetContext).pop(),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                key: const ValueKey('viewerTextOverlayField'),
                controller: controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.exportQuoteOverlayPlaceholder,
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(l10n.actionCancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(controller.text),
                      child: Text(l10n.actionApply),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (text == null) return;

    setState(() => _textOverlay.applyEdit(text));
    await _textOverlay.save();
  }

  @override
  String? get _activeQuoteText => _textOverlay.activeQuoteText;

  Future<void> _toggleFractalMusic() async {
    final controller = _activeController(context);
    final enabling = !_viewerEffects.fractalMusicEnabled;
    final scanFrame = enabling ? await _captureFractalMusicScanFrame() : null;
    final result = await _viewerEffects.toggleFractalMusic(
      controller,
      scanFrame: scanFrame,
    );
    if (!mounted) return;

    setState(() {});
    _syncFractalMusicScanAnimation(result.enabled);
    if (result.enabled) {
      _musicCoordinator.startLoopRefresh(controller, scanFrame: scanFrame);
    }
    final l10n = AppLocalizations.of(context);
    if (result.failed) {
      final message = l10n?.fractalMusicUnavailable ??
          'Fractal Music unavailable. Check your audio device.';
      AccessibilityService.announce(message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    AccessibilityService.announce(
      result.enabled
          ? (l10n?.tooltipFractalMusicOn ?? 'Fractal Music on')
          : (l10n?.tooltipFractalMusicOff ?? 'Fractal Music off'),
    );
    HapticService.light();
  }

  void _syncFractalMusicScanAnimation(bool enabled) {
    if (enabled) {
      // Music playback restarts from the beginning whenever the visual scan is
      // rebuilt, so reset the visible beam too. Otherwise the sonification can
      // be correct but feel detached from the scanner overlay.
      _musicScanController.stop();
      _musicScanController.value = 0;
      _musicScanController.repeat();
    } else {
      _musicCoordinator.cancelRescan();
      _musicScanController.stop();
      _musicScanController.value = 0;
    }
  }

  Future<FractalMusicScanFrame?> _captureFractalMusicScanFrame() async {
    try {
      final renderObject =
          _activeBoundaryKey().currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return null;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !renderObject.attached || !renderObject.hasSize) {
        return null;
      }
      final image = await renderObject.toImage(pixelRatio: 0.25);
      try {
        final bytes =
            await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (bytes == null) return null;
        return FractalMusicScanFrame(
          rgba: Uint8List.fromList(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          ),
          width: image.width,
          height: image.height,
        );
      } finally {
        image.dispose();
      }
    } catch (_) {
      return null;
    }
  }

  void _toggleFullscreenUnobtrusive() {
    setState(() {
      _fullscreenUnobtrusive = !_fullscreenUnobtrusive;
    });
    final l10n = AppLocalizations.of(context);
    AccessibilityService.announce(
      _fullscreenUnobtrusive
          ? (l10n?.announceEnteredFullscreen ?? 'Entered fullscreen view')
          : (l10n?.announceExitedFullscreen ?? 'Exited fullscreen view'),
    );
    HapticService.light();
  }

  @override
  FractalController _activeController(BuildContext context) {
    if (_compareMode && _activePane == 1 && _compareController != null) {
      return _compareController!;
    }
    return context.read<FractalController>();
  }

  @override
  GlobalKey _activeBoundaryKey() {
    if (_compareMode && _activePane == 1) return _fractalKeyB;
    return _fractalKeyA;
  }

  void _toggleKaleidoscope(BuildContext context) {
    final controller = _activeController(context);
    controller.setKaleidoscopeEnabled(!controller.kaleidoscopeEnabled);
  }

  Uri _shareUriFor(FractalController controller) {
    return DeepLinkService.buildWebUri(
      moduleId: controller.module.id,
      params: controller.params,
      view: controller.view,
      transparentBackground: controller.transparentBackground,
      rotationLocked: controller.rotationLocked,
      glowEnabled: controller.glowEnabled,
      glowSigma: controller.glowSigma,
      glowIntensity: controller.glowIntensity,
      kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
      kaleidoscopeSectors: controller.kaleidoscopeSectors,
      kaleidoscopeMirror: controller.kaleidoscopeMirror,
      kaleidoscopeRotation: controller.kaleidoscopeRotation,
      kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode,
      includeDefaults: true,
    );
  }

  void _openShareLink(BuildContext context) {
    final controller = _activeController(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(
        uri: _shareUriFor(controller),
        fractalName: controller.module.displayName(l10n),
      ),
    );
  }

  Future<void> _reportFractal(BuildContext context) async {
    const tags = ViewerEffectsController.defaultReportTags;
    final controller = _activeController(context);
    final l10n = AppLocalizations.of(context)!;
    final selected = <String>{};
    final notes = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: AppBottomSheet(
            maxHeightFactor: 0.66,
            children: [
              AppBottomSheetHeader(
                icon: Icons.report_problem_rounded,
                iconGradient: const LinearGradient(
                  colors: [AppColors.warning, Color(0xFFFF7A45)],
                ),
                title: 'Report rendering issue',
                subtitle: controller.module.displayName(l10n),
                onClose: () => Navigator.of(sheetContext).pop(false),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick every symptom you see',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'This saves the current view, params, and tags.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final tag in tags)
                            _ReportTagChip(
                              label: tag,
                              selected: selected.contains(tag),
                              onTap: () => setSheetState(() {
                                if (!selected.remove(tag)) selected.add(tag);
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Notes',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: notes,
                        minLines: 3,
                        maxLines: 4,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Optional details for the fix pass',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor:
                              AppColors.surfaceVariant.withValues(alpha: 0.72),
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.7),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: AppColors.primaryLight,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(
                            color: AppColors.borderLight.withValues(alpha: 0.7),
                          ),
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () => Navigator.of(sheetContext).pop(true),
                        child: const Text('Save report'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved != true) {
      notes.dispose();
      return;
    }

    try {
      final reportTags = selected.toList();
      final moduleName = controller.module.displayName(l10n);
      final shareUrl = _shareUriFor(controller).toString();
      if (!kIsWeb && Platform.isAndroid) {
        final json = _viewerEffects.buildFractalReportJson(
          controller: controller,
          moduleName: moduleName,
          tags: reportTags,
          shareUrl: shareUrl,
          notes: notes.text,
        );
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Copy report JSON'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(child: SelectableText(json)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: json));
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report JSON copied')),
                    );
                  }
                },
                child: const Text('Copy'),
              ),
            ],
          ),
        );
        return;
      }

      final file = await _viewerEffects.saveFractalReport(
        controller: controller,
        moduleName: moduleName,
        tags: reportTags,
        shareUrl: shareUrl,
        notes: notes.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved report: ${file.path}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report failed: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      notes.dispose();
    }
  }

  void _cycleColorScheme(BuildContext context) {
    final controller = _activeController(context);
    final current = controller.params['colorScheme'];
    var max = 63;
    for (final param in controller.module.parameters) {
      if (param.id == 'colorScheme') {
        max = param.max.round();
        break;
      }
    }
    final value = current is num ? current.round() : 0;
    controller.updateParam('colorScheme', value >= max ? 0 : value + 1);
  }

  void _openPalettePicker(BuildContext context) {
    final controller = _activeController(context);
    final l10n = AppLocalizations.of(context)!;
    FractalParameter? colorParam;
    for (final param in controller.module.parameters) {
      if (param.id == 'colorScheme') {
        colorParam = param;
        break;
      }
    }
    final options = colorParam?.options ?? const <FractalParamOption>[];
    if (options.isEmpty) {
      _cycleColorScheme(context);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final current = controller.params['colorScheme'];
          return AppBottomSheet(
            maxHeightFactor: 0.68,
            children: [
              AppBottomSheetHeader(
                icon: Icons.palette_rounded,
                title: l10n.paramColorScheme,
                subtitle: 'Choose a palette for this render.',
                onClose: () => Navigator.of(context).pop(),
              ),
              Flexible(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.86,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = option.value == current;
                    return _PaletteChoiceTile(
                      label: option.label(l10n),
                      value: option.value,
                      selected: selected,
                      onTap: () {
                        controller.updateParam('colorScheme', option.value);
                        setSheetState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  KeyEventResult _onKeyEvent(BuildContext context, KeyEvent event) =>
      _viewerOnKeyEvent(this, context, event);

  void _ensureCompareController(BuildContext context) =>
      _viewerEnsureCompareController(this, context);

  void _jumpToRandomFractal(BuildContext context) =>
      _viewerJumpToRandomFractal(this, context);

  void _onRandomFractalFab(BuildContext context) =>
      _viewerOnRandomFractalFab(this, context);

  /// Records the current location in history.
  void _recordHistory(BuildContext context) => _viewerRecordHistory(context);

  Widget _buildTopFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) =>
      _viewerBuildTopFab(
        icon: icon,
        tooltip: tooltip,
        onPressed: onPressed,
      );

  Widget _buildViewerTitleChip(
    BuildContext context,
    FractalController controller,
  ) =>
      _viewerBuildViewerTitleChip(context, controller);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    final decision = _backendDecision.toLogLine(moduleId: controller.module.id);
    if (_lastBackendDecisionLogged != decision) {
      _lastBackendDecisionLogged = decision;
      if (kDebugMode) debugPrint(decision);
    }

    if (_compareMode) {
      _ensureCompareController(context);
    }

    return Focus(
        autofocus: true,
        focusNode: _keyboardFocusNode,
        onKeyEvent: (node, event) => _onKeyEvent(context, event),
        child: Scaffold(
          extendBody: true,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final activeController = _activeController(context);
              final topInset = MediaQuery.of(context).padding.top;
              final overlayTop = topInset + 56;

              return Stack(
                children: [
                  // Fractal renderer (single or compare)
                  Positioned.fill(
                    child: _compareMode
                        ? CompareRenderer(
                            keyA: _fractalKeyA,
                            keyB: _fractalKeyB,
                            controllerB: _compareController!,
                            sliderMode: _compareSliderMode,
                            divider: _compareDivider,
                            activePane: _activePane,
                            onDividerChanged: (v) =>
                                setState(() => _compareDivider = v),
                            onActivePaneChanged: (pane) =>
                                setState(() => _activePane = pane),
                            onOpenControls: () => _toggleControlsHud(),
                            onOpenPresets: () => _openPresets(context),
                            onOpenExport: () => _openExport(context),
                            onUserInteraction: _onAutoExploreUserCorrection,
                            onUserInteractionStart:
                                _onAutoExploreUserInteractionStart,
                            onUserInteractionEnd:
                                _onAutoExploreUserInteractionEnd,
                            freezeFrame: !_liveRenderingEnabled,
                          )
                        : (_backendDecision.backend == RendererBackend.cpu
                            ? FractalRenderer(
                                renderPlan: _currentRendererPlan(controller),
                                animationEnabled: _liveRenderingEnabled,
                                onOpenControls: _usesCoreViewerChrome
                                    ? () => _toggleControlsHud()
                                    : null,
                                onOpenPresets: _usesCoreViewerChrome
                                    ? () => _openPresets(context)
                                    : null,
                                onOpenExport: _usesCoreViewerChrome
                                    ? () => _openExport(context)
                                    : null,
                                onUserInteraction: _onAutoExploreUserCorrection,
                                onUserInteractionStart:
                                    _onAutoExploreUserInteractionStart,
                                onUserInteractionEnd:
                                    _onAutoExploreUserInteractionEnd,
                                overrideChild: CpuFallbackPane(
                                  boundaryKey: _fractalKeyA,
                                  initialSnapshot: _lastGpuSnapshot,
                                  onSnapshotFadeComplete: () {
                                    final snapshot = _lastGpuSnapshot;
                                    setState(() {
                                      _lastGpuSnapshot = null;
                                    });
                                    snapshot?.dispose();
                                  },
                                ),
                              )
                            : FractalRenderer(
                                boundaryKey: _fractalKeyA,
                                renderPlan: _currentRendererPlan(controller),
                                animationEnabled: _liveRenderingEnabled,
                                onOpenControls: _usesCoreViewerChrome
                                    ? () => _toggleControlsHud()
                                    : null,
                                onOpenPresets: _usesCoreViewerChrome
                                    ? () => _openPresets(context)
                                    : null,
                                onOpenExport: _usesCoreViewerChrome
                                    ? () => _openExport(context)
                                    : null,
                                onUserInteraction: _onAutoExploreUserCorrection,
                                onUserInteractionStart:
                                    _onAutoExploreUserInteractionStart,
                                onUserInteractionEnd:
                                    _onAutoExploreUserInteractionEnd,
                              )),
                  ),

                  if (_viewerEffects.fractalMusicEnabled)
                    Positioned.fill(
                      child: FractalMusicScanOverlay(
                        animation: _musicScanController,
                      ),
                    ),

                  if (_activeQuoteText != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Text(
                              _activeQuoteText!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (constraints.maxWidth / 12)
                                    .clamp(28.0, 72.0),
                                fontWeight: FontWeight.w800,
                                height: 1.08,
                                foreground: Paint()
                                  ..blendMode = BlendMode.difference
                                  ..color = Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_fullscreenUnobtrusive && !widget.captureMode)
                    Positioned(
                      right: AppSpacing.lg,
                      bottom:
                          MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                      child: _buildTopFab(
                        icon: Icons.fullscreen_exit_rounded,
                        tooltip: l10n.tooltipExitFullscreen,
                        onPressed: _toggleFullscreenUnobtrusive,
                      ),
                    ),

                  if (_showCoreViewerChrome)
                    Positioned(
                      top: overlayTop,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildViewerTitleChip(context, controller),
                        ],
                      ),
                    ),

                  if (_showCoreViewerChrome &&
                      _backendDecision.backend == RendererBackend.cpu)
                    Positioned(
                      top: overlayTop,
                      right: 12,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: CpuFallbackBanner(
                          onTryGpu: () {
                            // Switch back to Auto so policy can try GPU again.
                            context
                                .read<RendererSettingsService>()
                                .setBackendMode(RendererBackendMode.auto);
                            setState(() {
                              _gpuProbe.resetHealth();
                              _refreshBackendDecision();
                            });
                          },
                          onReport: () => _shareGpuDebugReport(context),
                        ),
                      ),
                    ),

                  // Deep-zoom precision indicator
                  if (_showCoreViewerChrome &&
                      _deepZoomPrecisionActive &&
                      _backendDecision.backend != RendererBackend.cpu)
                    Positioned(
                      top: overlayTop,
                      right: 12,
                      child: Semantics(
                        label: 'Switch to CPU for deep zoom',
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            context
                                .read<RendererSettingsService>()
                                .setBackendMode(RendererBackendMode.cpuOnly);
                            setState(() {
                              _refreshBackendDecision();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.cyan.withValues(alpha: 0.7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.precision_manufacturing_rounded,
                                    color: Colors.cyan, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  l10n.deepZoomCpuFallback,
                                  style: const TextStyle(
                                      color: Colors.cyan, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned.fill(
                    child: AutoPilotAlignmentOverlay(
                      service: _autoExploreService,
                    ),
                  ),

                  // Floating action buttons.
                  // Bound the region vertically (top + bottom) so the inner
                  // SingleChildScrollView gets a finite height and can actually
                  // scroll. Without a `top`, the column of buttons was given
                  // unbounded height and overflowed off the top of short
                  // viewports (landscape phones / small web windows), pushing
                  // the upper buttons off-screen and over the status chips.
                  if (_showCoreViewerChrome)
                    Positioned(
                      top: overlayTop,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom:
                          MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                      child: FractalViewControls(
                        fabController: _fabController,
                        isExporting: _exporting,
                        kaleidoscopeEnabled:
                            activeController.kaleidoscopeEnabled,
                        kaleidoscopeSectors:
                            activeController.kaleidoscopeSectors,
                        kaleidoscopeMirror: activeController.kaleidoscopeMirror,
                        fractalMusicEnabled: _viewerEffects.fractalMusicEnabled,
                        textOverlayEnabled: _textOverlay.enabled,
                        showFractalReport:
                            !kIsWeb && (Platform.isLinux || Platform.isAndroid),
                        actions: FractalViewControlActions(
                          toggleFullscreen: _toggleFullscreenUnobtrusive,
                          openRandomFractal: () => _onRandomFractalFab(context),
                          openControls: () => _toggleControlsHud(),
                          randomizeParams: () {
                            HapticFeedback.mediumImpact();
                            final activeController = _activeController(context);
                            activeController.randomizeParams();
                          },
                          cycleColorScheme: () => _cycleColorScheme(context),
                          openPalettePicker: () => _openPalettePicker(context),
                          toggleKaleidoscope: () =>
                              _toggleKaleidoscope(context),
                          setKaleidoscopeSectors: (sectors) {
                            final activeController = _activeController(context);
                            activeController.setKaleidoscopeEnabled(true);
                            activeController.setKaleidoscopeSectors(sectors);
                          },
                          setKaleidoscopeMirror: (value) {
                            final activeController = _activeController(context);
                            activeController.setKaleidoscopeEnabled(true);
                            activeController.setKaleidoscopeMirror(value);
                          },
                          openExport: () => _openExport(context),
                          shareLink: () => _openShareLink(context),
                          shareImage: () => _shareCurrentImage(context),
                          toggleTextOverlay: _toggleTextOverlay,
                          editTextOverlay: _editTextOverlay,
                          openLooper: () => _openLooper(context),
                          toggleFractalMusic: _toggleFractalMusic,
                          reportFractal: () => _reportFractal(context),
                          openWallpaper: () => _openWallpaper(context),
                        ),
                      ),
                    ),

                  // Controls HUD overlay (replaces bottom sheet modal)
                  if (_usesCoreViewerChrome && _showControlsHud)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: MediaQuery.of(context).size.height * 0.42,
                      child: ChangeNotifierProvider.value(
                        value: controller,
                        child: FractalControlsHud(
                          onClose: _toggleControlsHud,
                        ),
                      ),
                    ),

                  // Export progress overlay
                  if (_exporting)
                    Positioned.fill(
                      child: ExportOverlay(
                        progress: _exportProgress,
                        l10n: l10n,
                      ),
                    ),
                ],
              );
            },
          ),
        ));
  }
}

class _PaletteChoiceTile extends StatelessWidget {
  final String label;
  final Object value;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteChoiceTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.surfaceVariant.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryLight : AppColors.glassBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: _paletteGradient(value),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 17,
                          color: AppColors.primaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 10,
                  height: 1.05,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _paletteGradient(Object value) {
    if (value is num) {
      try {
        final stops = PaletteService.instance
            .paletteAtIndex(value.round())
            .stops
            .map((stop) => Color(stop.colorArgb))
            .toList();
        if (stops.length >= 2) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: stops,
          );
        }
      } catch (_) {
        // PaletteService is unavailable only in narrow widget harnesses.
      }
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2B0B0B), Color(0xFFFF5E3A), Color(0xFFFFC857)],
    );
  }
}

class _ReportTagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReportTagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetChoicePill(
      label: label,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _SheetChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SheetChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.22)
                : AppColors.surfaceVariant.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primaryLight
                  : AppColors.borderLight.withValues(alpha: 0.62),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
