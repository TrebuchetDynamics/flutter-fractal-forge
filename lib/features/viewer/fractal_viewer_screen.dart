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
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' show Vector2;
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/services/exploration_stats_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/debug/shader_lab_screen.dart';
import 'package:flutter_fractals/features/export/batch_export_dialog.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/minimap/fractal_minimap.dart';
import 'package:flutter_fractals/features/renderer/backend_policy.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_fractals/core/services/app_logger_service.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/features/viewer/rendering/compare_renderer.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';

part 'diagnostics/viewer_gpu_health.dart';
part 'diagnostics/viewer_debug_report.dart';
part 'dialogs/viewer_dialogs.dart';
part 'export/viewer_export_actions.dart';
part 'navigation/viewer_interactions.dart';
part 'navigation/viewer_history.dart';
part 'overlays/viewer_hud.dart';

class FractalViewerScreen extends StatefulWidget {
  const FractalViewerScreen({Key? key}) : super(key: key);

  @override
  State<FractalViewerScreen> createState() => _FractalViewerScreenState();
}

class _FractalViewerScreenState extends State<FractalViewerScreen>
    with
        TickerProviderStateMixin,
        _GpuHealthMixin,
        _DebugReportMixin,
        _ExportActionsMixin,
        _ViewerDialogsMixin {
  bool get _isTest => RuntimeModeService.isAutomatedTest;

  @override
  final GlobalKey _fractalKeyA = GlobalKey();
  final GlobalKey _fractalKeyB = GlobalKey();
  @override
  final ExportService _exportService = const ExportService();

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

  // Visual simplification state
  bool _showMiniMap = false;
  bool _fullscreenUnobtrusive = false;

  // History tracking
  FractalController? _lastController;

  // Exploration stats tracking
  ExplorationStatsService? _statsService;
  DateTime? _sessionStart;
  double? _lastZoom;
  String? _lastModuleId;

  // Auto-explore service
  @override
  AutoExploreService? _autoExploreService;

  String? _lastBackendDecisionLogged;
  Timer? _backendDebounceTimer;

  @override
  final AppLogger _log = AppLogger.instance;
  final FocusNode _keyboardFocusNode =
      FocusNode(debugLabel: 'fractal-viewer-keyboard-focus');

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    )..forward();
    _log.info('lifecycle', 'FractalViewerScreen initState');
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

    // Grab stats service (optional in tests)
    _statsService ??= context.read<ExplorationStatsService?>();

    // Start session timer once.
    _sessionStart ??= DateTime.now();

    // Set up history + stats tracking
    final controller = context.read<FractalController>();
    if (_lastController != controller) {
      _lastController?.removeListener(_onControllerChanged);
      _lastController = controller;

      _lastZoom = controller.view.zoom;
      _lastModuleId = controller.module.id;
      _statsService?.recordFractalExplored(controller.module.id);

      controller.addListener(_onControllerChanged);
      // Record initial state
      _recordHistory(context);

      _gpuHealthFailed = false;
      _refreshBackendDecision();
      _scheduleGpuHealthCheck();
      _detectEmulatorProfile();

      // Initialize auto-explore service
      _autoExploreService?.dispose();
      _autoExploreService = AutoExploreService(controller: controller);
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
    if (_lastModuleId != null && _lastModuleId != controller.module.id) {
      _gpuHealthFailed = false;
      _gpuHealthFailureStreak = 0;
      _scheduleGpuHealthCheck();
    }

    // Deep-zoom precision indicator — uses same hysteresis state as decision
    // so the UI badge and backend decision stay in sync.
    final dzActive = _dzHysteresis.update(
      moduleId: controller.module.id,
      zoom: controller.view.zoom,
    );
    if (dzActive != _deepZoomPrecisionActive) {
      _deepZoomPrecisionActive = dzActive;
    }
    _refreshBackendDecision();

    // Record view/config changes into history
    _recordHistory(context);

    // Best-effort stats tracking (local-only)

    // Zoom distance: sum abs(log(new/old))
    final prevZoom = _lastZoom;
    final currentZoom = controller.view.zoom;
    if (prevZoom != null &&
        prevZoom > 0 &&
        currentZoom > 0 &&
        prevZoom != currentZoom) {
      final delta = (math.log(currentZoom / prevZoom)).abs();
      _statsService?.addZoomDistance(delta);
      _lastZoom = currentZoom;
    }

    // Unique fractals explored
    final currentId = controller.module.id;
    if (_lastModuleId != currentId) {
      _log.logState('action', 'Module changed', {
        'from': _lastModuleId,
        'to': currentId,
      });
      _lastModuleId = currentId;
      _statsService?.recordFractalExplored(currentId);
    }
  }

  @override
  void dispose() {
    _gpuHealthTimer?.cancel();
    _backendDebounceTimer?.cancel();
    _lastController?.removeListener(_onControllerChanged);

    final start = _sessionStart;
    if (start != null) {
      final elapsed = DateTime.now().difference(start);
      _statsService?.addExploreTime(elapsed);
    }

    _lastGpuSnapshot?.dispose();
    _fabController.dispose();
    _debugRunner?.dispose();
    _autoExploreService?.dispose();
    _compareController?.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
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

  void _toggleMiniMapVisibility() {
    setState(() {
      _showMiniMap = !_showMiniMap;
    });
    final l10n = AppLocalizations.of(context);
    AccessibilityService.announce(
      _showMiniMap
          ? (l10n?.announceMinimapShown ?? 'Minimap shown')
          : (l10n?.announceMinimapHidden ?? 'Minimap hidden'),
    );
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
    required String heroTag,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) =>
      _viewerBuildTopFab(
        heroTag: heroTag,
        icon: icon,
        tooltip: tooltip,
        onPressed: onPressed,
      );

  Widget _buildViewerTitleChip(
    BuildContext context,
    FractalController controller,
  ) =>
      _viewerBuildViewerTitleChip(context, controller);

  String _formatZoomLabel(double zoom) => _viewerFormatZoomLabel(zoom);

  Widget _buildViewerStatusChip(
    BuildContext context,
    FractalController controller,
  ) =>
      _viewerBuildViewerStatusChip(this, context, controller);

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
              final viewportSize =
                  Size(constraints.maxWidth, constraints.maxHeight);
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
                            onOpenControls: () => _openControls(context),
                            onOpenPresets: () => _openPresets(context),
                            onOpenExport: () => _openExport(context),
                            onUserInteraction: _onAutoExploreUserCorrection,
                            onUserInteractionStart:
                                _onAutoExploreUserInteractionStart,
                            onUserInteractionEnd:
                                _onAutoExploreUserInteractionEnd,
                            freezeFrame: _freezeFrameForExport,
                          )
                        : (_backendDecision.backend == RendererBackend.cpu
                            ? FractalRenderer(
                                animationEnabled: !_freezeFrameForExport,
                                onOpenControls: () => _openControls(context),
                                onOpenPresets: () => _openPresets(context),
                                onOpenExport: () => _openExport(context),
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
                                animationEnabled: !_freezeFrameForExport,
                                onOpenControls: () => _openControls(context),
                                onOpenPresets: () => _openPresets(context),
                                onOpenExport: () => _openExport(context),
                                onUserInteraction: _onAutoExploreUserCorrection,
                                onUserInteractionStart:
                                    _onAutoExploreUserInteractionStart,
                                onUserInteractionEnd:
                                    _onAutoExploreUserInteractionEnd,
                              )),
                  ),

                  if (_fullscreenUnobtrusive)
                    Positioned(
                      top: topInset + 8,
                      right: AppSpacing.md,
                      child: _buildTopFab(
                        heroTag: 'viewer_restore_ui_fab',
                        icon: Icons.fullscreen_exit_rounded,
                        tooltip: l10n.tooltipExitFullscreen,
                        onPressed: _toggleFullscreenUnobtrusive,
                      ),
                    ),

                  if (!_fullscreenUnobtrusive)
                    Positioned(
                      top: overlayTop,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildViewerTitleChip(context, controller),
                          const SizedBox(height: 6),
                          _buildViewerStatusChip(context, controller),
                        ],
                      ),
                    ),

                  if (!_fullscreenUnobtrusive &&
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
                              _gpuHealthFailed = false;
                              _refreshBackendDecision();
                            });
                          },
                          onReport: () => _shareGpuDebugReport(context),
                        ),
                      ),
                    ),

                  // Deep-zoom precision indicator
                  if (!_fullscreenUnobtrusive &&
                      _deepZoomPrecisionActive &&
                      _backendDecision.backend != RendererBackend.cpu)
                    Positioned(
                      top: overlayTop,
                      right: 12,
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

                  // Minimap overlay (optional, hidden by default to reduce clutter)
                  if (!_fullscreenUnobtrusive && _showMiniMap)
                    Positioned(
                      left: AppSpacing.lg,
                      bottom:
                          MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                      child: ChangeNotifierProvider.value(
                        value: _activeController(context),
                        child: FractalMiniMap(viewportSize: viewportSize),
                      ),
                    ),

                  // Floating action buttons
                  if (!_fullscreenUnobtrusive)
                    Positioned(
                      right: AppSpacing.lg,
                      bottom:
                          MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                      child: FractalViewControls(
                        fabController: _fabController,
                        autoExploreService: _autoExploreService,
                        isExporting: _exporting,
                        backTooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                        onGoBack: () => Navigator.of(context).pop(),
                        onToggleFullscreen: _toggleFullscreenUnobtrusive,
                        onOpenAutoExploreSettings: () =>
                            _openAutoExploreSettings(context),
                        onOpenRandomFractal: () => _onRandomFractalFab(context),
                        onOpenControls: () => _openControls(context),
                        onOpenExport: () => _openExport(context),
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
