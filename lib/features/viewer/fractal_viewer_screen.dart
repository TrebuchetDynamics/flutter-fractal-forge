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
import 'package:share_plus/share_plus.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/haptic_service.dart';
import 'package:flutter_fractals/core/services/wallpaper_service.dart';
import 'package:flutter_fractals/core/models/wallpaper_options.dart';
import 'package:flutter_fractals/core/services/performance_service.dart';
import 'package:flutter_fractals/core/services/exploration_stats_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/debug/debug_overlay.dart';
import 'package:flutter_fractals/features/debug/performance_overlay.dart';
import 'package:flutter_fractals/features/debug/shader_debug_overlay.dart';
import 'package:flutter_fractals/features/ar/ar_overlay_screen.dart';
import 'package:flutter_fractals/features/debug/shader_lab_screen.dart';
import 'package:flutter_fractals/features/export/batch_export_dialog.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/export/video_export_sheet.dart';
import 'package:flutter_fractals/core/models/video_export_options.dart';
import 'package:flutter_fractals/core/services/video_export_service.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/history/history_sheet.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/minimap/fractal_minimap.dart';
import 'package:flutter_fractals/features/renderer/backend_policy.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_fractals/core/services/app_logger_service.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/features/debug/log_viewer_screen.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/features/viewer/components/fractal_app_bar.dart';
import 'package:flutter_fractals/features/viewer/components/fractal_view_controls.dart';
import 'package:flutter_fractals/features/viewer/components/cpu_fallback_pane.dart';
import 'package:flutter_fractals/features/viewer/components/compare_renderer.dart';
import 'package:flutter_fractals/features/viewer/components/viewer_export_overlay.dart';

part 'viewer_gpu_health.dart';
part 'viewer_debug_report.dart';
part 'viewer_dialogs.dart';
part 'viewer_export_actions.dart';

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
  @override
  final WallpaperService _wallpaperService = const WallpaperService();

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

  // Performance overlay state
  final PerformanceService _performanceService = PerformanceService();
  bool _showPerformanceOverlay = false;
  bool _compactPerformanceOverlay = false;

  // Dev-only shader debug overlay (shows uniform values)
  final bool _showShaderDebug = false;

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

  void _onControllerChanged() {
    if (!mounted) return;

    final controller = context.read<FractalController>();
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
    _performanceService.dispose();
    _autoExploreService?.dispose();
    _compareController?.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _togglePerformanceOverlay() {
    setState(() {
      _showPerformanceOverlay = !_showPerformanceOverlay;
      if (_showPerformanceOverlay) {
        _performanceService.start(this);
      } else {
        _performanceService.stop();
      }
    });
  }

  void _toggleCompactMode() {
    setState(() {
      _compactPerformanceOverlay = !_compactPerformanceOverlay;
    });
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

  KeyEventResult _onKeyEvent(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final controller = _activeController(context);
    const panStep = 0.08;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final pan = controller.view.pan;
      controller.updatePan(Vector2(pan.x - panStep, pan.y));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final pan = controller.view.pan;
      controller.updatePan(Vector2(pan.x + panStep, pan.y));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final pan = controller.view.pan;
      controller.updatePan(Vector2(pan.x, pan.y - panStep));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final pan = controller.view.pan;
      controller.updatePan(Vector2(pan.x, pan.y + panStep));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.minus ||
        event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
      controller.updateZoom(controller.view.zoom / 1.2);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.equal ||
        event.logicalKey == LogicalKeyboardKey.numpadAdd) {
      controller.updateZoom(controller.view.zoom * 1.2);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      controller.resetView();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _ensureCompareController(BuildContext context) {
    if (_compareController != null) return;
    final registry = context.read<ModuleRegistry>();
    _compareController = FractalController(registry);

    // Initialize B from A.
    final a = context.read<FractalController>();
    _compareController!.selectModule(a.module, animate: false);
    for (final entry in a.params.entries) {
      _compareController!.updateParam(entry.key, entry.value);
    }
    _compareController!.updatePan(a.view.pan);
    _compareController!.updateZoom(a.view.zoom);
    _compareController!.updateRotation(a.view.rotation);
    _compareController!.setTransparentBackground(a.transparentBackground);
  }

  void _jumpToRandomFractal(BuildContext context) {
    _log.info('action', 'Random fractal');
    final registry = context.read<ModuleRegistry>();
    final controller = context.read<FractalController>();
    final currentId = controller.module.id;
    // Filter to real fractals (skip diagnostics)
    final candidates = registry.modules
        .where((m) =>
            m.id != currentId &&
            !m.id.contains('diag') &&
            !m.id.contains('gradient'))
        .toList();
    if (candidates.isEmpty) return;
    final rng = math.Random();
    final pick = candidates[rng.nextInt(candidates.length)];
    controller.selectModule(pick);
  }

  void _applyHistoryEntry(BuildContext context, HistoryEntry entry) {
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

  void _goHistoryBack(BuildContext context) {
    final historyProvider = context.read<HistoryProvider?>();
    if (historyProvider == null) return;
    final entry = historyProvider.goBack();
    if (entry == null) return;
    _applyHistoryEntry(context, entry);
    AccessibilityService.announce('Moved to previous view');
  }

  void _goHistoryForward(BuildContext context) {
    final historyProvider = context.read<HistoryProvider?>();
    if (historyProvider == null) return;
    final entry = historyProvider.goForward();
    if (entry == null) return;
    _applyHistoryEntry(context, entry);
    AccessibilityService.announce('Moved to next view');
  }

  /// Records the current location in history.
  void _recordHistory(BuildContext context) {
    final controller = context.read<FractalController>();
    final historyProvider = context.read<HistoryProvider?>();
    if (historyProvider == null) return;

    historyProvider.recordLocation(
      moduleId: controller.module.id,
      view: controller.view,
      params: controller.params,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final rendererSettings = context.watch<RendererSettingsService>();
    final historyProvider = context.watch<HistoryProvider?>();
    final backendMode = rendererSettings.backendMode;

    // Debounce backend decision refresh to prevent excessive recalculation
    _backendDebounceTimer?.cancel();
    _backendDebounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (mounted) {
        _refreshBackendDecision();
      }
    });

    final decision = _backendDecision.toLogLine(moduleId: controller.module.id);
    if (_lastBackendDecisionLogged != decision) {
      _lastBackendDecisionLogged = decision;
      debugPrint(decision);
    }

    if (_compareMode) {
      _ensureCompareController(context);
    }

    return Focus(
        autofocus: true,
        focusNode: _keyboardFocusNode,
        onKeyEvent: (node, event) => _onKeyEvent(context, event),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: FractalAppBar(
            title: controller.module.displayName(l10n),
            statusText: _backendDecision.toUserStatusText(),
            onBack: () => Navigator.of(context).pop(),
            actions: [
              if (kDebugMode)
                AppBarIconButton(
                  icon: Icons.bug_report_rounded,
                  tooltip: l10n.tooltipGpuDebug,
                  onPressed: () => _shareGpuDebugReport(context),
                ),
              AppBarIconButton(
                icon: switch (backendMode) {
                  RendererBackendMode.auto => Icons.auto_mode_rounded,
                  RendererBackendMode.cpuOnly => Icons.computer_rounded,
                  RendererBackendMode.gpuOnly => Icons.flash_on_rounded,
                },
                tooltip: switch (backendMode) {
                  RendererBackendMode.auto => l10n.rendererAuto,
                  RendererBackendMode.cpuOnly => l10n.rendererCpu,
                  RendererBackendMode.gpuOnly => l10n.rendererGpu,
                },
                onPressed: () => _openBackendModePicker(context),
              ),
              AppBarIconButton(
                icon: controller.rotationLocked
                    ? Icons.screen_lock_rotation_rounded
                    : Icons.screen_rotation_alt_rounded,
                tooltip: controller.rotationLocked
                    ? 'Unlock rotation gestures'
                    : 'Lock rotation gestures',
                onPressed: () {
                  controller.toggleRotationLock();
                  final locked = controller.rotationLocked;
                  AccessibilityService.announce(
                    locked ? 'Rotation locked' : 'Rotation unlocked',
                  );
                  HapticFeedback.selectionClick();
                },
              ),
              if (historyProvider != null && historyProvider.canGoBack)
                AppBarIconButton(
                  icon: Icons.undo_rounded,
                  tooltip: 'Back in view history',
                  onPressed: () => _goHistoryBack(context),
                ),
              if (historyProvider != null && historyProvider.canGoForward)
                AppBarIconButton(
                  icon: Icons.redo_rounded,
                  tooltip: 'Forward in view history',
                  onPressed: () => _goHistoryForward(context),
                ),
              AppBarIconButton(
                icon: Icons.camera_rounded,
                tooltip: 'AR',
                onPressed: () {
                  final controller = context.read<FractalController>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: controller,
                        child: const ArOverlayScreen(),
                      ),
                    ),
                  );
                },
              ),
              // Random fractal picker
              AppBarIconButton(
                icon: Icons.shuffle_rounded,
                tooltip: l10n.tooltipRandomFractal,
                onPressed: () => _jumpToRandomFractal(context),
              ),
              AppBarIconButton(
                icon: Icons.receipt_long_rounded,
                tooltip: 'View Log',
                onPressed: () {
                  _log.logState('state', 'Snapshot at log open', {
                    'module': controller.module.id,
                    'panX': controller.view.pan.x,
                    'panY': controller.view.pan.y,
                    'zoom': controller.view.zoom,
                    'iterations': controller.params['iterations'],
                    'backend': _backendDecision.backend.name,
                    'backendReason': _backendDecision.reasonToken,
                  });
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LogViewerScreen()),
                  );
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final viewportSize =
                  Size(constraints.maxWidth, constraints.maxHeight);

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
                            freezeFrame: _freezeFrameForExport,
                          )
                        : (_backendDecision.backend == RendererBackend.cpu
                            ? FractalRenderer(
                                animationEnabled: !_freezeFrameForExport,
                                onOpenControls: () => _openControls(context),
                                onOpenPresets: () => _openPresets(context),
                                onOpenExport: () => _openExport(context),
                                onUserInteraction: _onAutoExploreUserCorrection,
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
                            : ((controller.module.dimension ==
                                        FractalDimension.threeD) &&
                                    !_isTest
                                ? Center(
                                    child: Text(
                                      l10n.disable3dMessage,
                                      style: const TextStyle(
                                          color: Colors.white70),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : FractalRenderer(
                                    boundaryKey: _fractalKeyA,
                                    animationEnabled: !_freezeFrameForExport,
                                    onOpenControls: () =>
                                        _openControls(context),
                                    onOpenPresets: () => _openPresets(context),
                                    onOpenExport: () => _openExport(context),
                                    onUserInteraction:
                                        _onAutoExploreUserCorrection,
                                  ))),
                  ),

                  if (_backendDecision.backend == RendererBackend.cpu)
                    Positioned(
                      // Avoid overlapping the ShaderDebugOverlay which is positioned at top:80, left:8.
                      top: MediaQuery.of(context).padding.top + 8,
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
                  if (_deepZoomPrecisionActive &&
                      _backendDecision.backend != RendererBackend.cpu)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
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
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.cyan.withOpacity(0.7)),
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

                  // Minimap overlay (bottom-left)
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
                  Positioned(
                    right: AppSpacing.lg,
                    bottom:
                        MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                    child: FractalViewControls(
                      fabController: _fabController,
                      autoExploreService: _autoExploreService,
                      isExporting: _exporting,
                      onOpenAutoExploreSettings: () =>
                          _openAutoExploreSettings(context),
                      onOpenControls: () => _openControls(context),
                      onOpenPresets: () => _openPresets(context),
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

                  if (kDebugMode && _debugRunner != null)
                    DebugOverlay(
                      runner: _debugRunner!,
                      boundaryKey: _activeBoundaryKey(),
                    ),

                  // Dev-only performance overlay toggle button (top-left)
                  if (kDebugMode)
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          8,
                      left: AppSpacing.md,
                      child: GestureDetector(
                        onLongPress:
                            _showPerformanceOverlay ? _toggleCompactMode : null,
                        child: PerformanceToggleButton(
                          isEnabled: _showPerformanceOverlay,
                          onToggle: _togglePerformanceOverlay,
                        ),
                      ),
                    ),

                  // Dev-only performance overlay (top-left, below toggle)
                  if (kDebugMode && _showPerformanceOverlay)
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          48,
                      left: AppSpacing.md,
                      child: FractalPerformanceOverlay(
                        service: _performanceService,
                        compact: _compactPerformanceOverlay,
                      ),
                    ),

                  // Dev-only shader debug overlay (uniform values)
                  if (kDebugMode && _showShaderDebug)
                    ShaderDebugOverlay(
                      enabled: true,
                      canvasSize: viewportSize,
                    ),

                  // Export overlay
                  if (_exporting)
                    ExportOverlay(
                      progress: _exportProgress,
                      l10n: l10n,
                    ),
                ],
              );
            },
          ),
        ));
  }
}
