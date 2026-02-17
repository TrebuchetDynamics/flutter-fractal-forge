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

class FractalViewerScreen extends StatefulWidget {
  const FractalViewerScreen({Key? key}) : super(key: key);

  @override
  State<FractalViewerScreen> createState() => _FractalViewerScreenState();
}

class _FractalViewerScreenState extends State<FractalViewerScreen>
    with TickerProviderStateMixin {
  static const bool _forceGpuHealthProbeFailure = bool.fromEnvironment(
    'FORCE_GPU_HEALTH_PROBE_FAILURE',
    defaultValue: false,
  );

  bool get _isTest => RuntimeModeService.isAutomatedTest;

  final GlobalKey _fractalKeyA = GlobalKey();
  final GlobalKey _fractalKeyB = GlobalKey();
  final ExportService _exportService = const ExportService();
  final WallpaperService _wallpaperService = const WallpaperService();

  // Compare mode state
  final bool _compareMode = false;
  final bool _compareSliderMode =
      false; // false: side-by-side, true: sliding divider
  double _compareDivider = 0.5; // 0..1 (only used for slider mode)
  int _activePane = 0; // 0: A (primary/provider), 1: B (secondary)
  FractalController? _compareController;
  bool _exporting = false;
  double? _exportProgress;
  DebugRunnerService? _debugRunner;
  late AnimationController _fabController;

  // Performance overlay state
  final PerformanceService _performanceService = PerformanceService();
  bool _showPerformanceOverlay = false;
  bool _compactPerformanceOverlay = false;

  // Dev-only shader debug overlay (shows uniform values)
  final bool _showShaderDebug = false;

  bool _gpuHealthFailed = false;
  bool _isAndroidEmulator = false;
  double? _lastGpuDarkRatio;
  double? _lastGpuNonBlackRatio;
  bool? _lastGpuCenterNonBlack;
  bool? _lastGpuHistogramSane;
  int? _lastGpuSampleCount;
  Object? _lastGpuHealthError;
  Timer? _gpuHealthTimer;
  bool _gpuProbeActive = false;
  int _gpuProbeBackendSwitches = 0;
  int _gpuHealthFailureStreak = 0;
  final RendererBackendPolicy _backendPolicy = const RendererBackendPolicy();
  BackendDecision _backendDecision = const BackendDecision(
    backend: RendererBackend.gpu,
    reasonCode: FallbackReasonCode.none,
    detail: 'init',
  );
  ui.Image? _lastGpuSnapshot;

  // History tracking
  FractalController? _lastController;

  // Exploration stats tracking
  ExplorationStatsService? _statsService;
  DateTime? _sessionStart;
  double? _lastZoom;
  String? _lastModuleId;

  // Deep-zoom precision indicator + hysteresis filter
  // (avoids rapid GPU↔CPU flicker when zooming near the threshold)
  bool _deepZoomPrecisionActive = false;
  final DeepZoomHysteresis _dzHysteresis = DeepZoomHysteresis();

  // Auto-explore service
  AutoExploreService? _autoExploreService;

  // Freeze renderer while export sheet is open.
  bool _freezeFrameForExport = false;
  bool _resumeAutoExploreAfterExportSheet = false;
  String? _lastBackendDecisionLogged;
  Timer? _backendDebounceTimer;
  DateTime? _lastBackendSwitch;
  String? _lastBackendDecisionModuleId;

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

  Future<void> _detectEmulatorProfile() async {
    final isEmulator = await detectAndroidEmulator();
    if (!mounted) return;
    _log.logState(
        'lifecycle', 'Emulator detection', {'isEmulator': isEmulator});
    setState(() {
      _isAndroidEmulator = isEmulator;
      _refreshBackendDecision();
    });
  }

  void _refreshBackendDecision() {
    final controller = context.read<FractalController>();

    final mode = context.read<RendererSettingsService>().backendMode;

    final oldBackend = _backendDecision.backend;
    final currentModuleId = controller.module.id;
    final moduleChanged = _lastBackendDecisionModuleId != currentModuleId;

    // Reset hysteresis on module change so we start fresh for the new fractal.
    if (moduleChanged) _dzHysteresis.reset();

    final newDecision = _backendPolicy.decide(
      BackendPolicyInput(
        isAndroid: !kIsWeb && Platform.isAndroid,
        isWeb: kIsWeb,
        isEmulator: _isAndroidEmulator,
        userMode: mode,
        gpuHealthFailed: _gpuHealthFailed,
        deepZoomNeedsCpu: _dzHysteresis.update(
          moduleId: controller.module.id,
          zoom: controller.view.zoom,
        ),
        dimension: controller.module.dimension,
      ),
    );

    // Add hysteresis to prevent rapid backend switching (flicker bug)
    // Only switch if decision changed AND enough time has passed
    if (newDecision.backend != oldBackend) {
      if (oldBackend == RendererBackend.gpu &&
          newDecision.backend == RendererBackend.cpu) {
        unawaited(_captureLastGpuSnapshot());
      }
      if (_gpuProbeActive) {
        _gpuProbeBackendSwitches++;
      }
      _log.logState('render', 'Backend switch', {
        'from': oldBackend.name,
        'to': newDecision.backend.name,
        'reason': newDecision.reasonToken,
        'detail': newDecision.detail,
        'duringGpuProbe': _gpuProbeActive,
      });
    }
    if (newDecision.backend != _backendDecision.backend) {
      final now = DateTime.now();
      final lastSwitch = _lastBackendSwitch;

      // Module switches should always update immediately. The hysteresis is
      // only meant to prevent rapid CPU<->GPU flip-flopping on *the same* module
      // due to health-check/precision conditions.
      if (moduleChanged ||
          lastSwitch == null ||
          now.difference(lastSwitch).inMilliseconds >= 500) {
        _backendDecision = newDecision;
        _lastBackendSwitch = now;
      }
      // Else: keep old decision to prevent flicker
    } else {
      // Same backend, update decision immediately
      _backendDecision = newDecision;
    }

    _lastBackendDecisionModuleId = currentModuleId;
  }

  Future<void> _captureLastGpuSnapshot() async {
    try {
      final boundaryContext = _fractalKeyA.currentContext;
      if (boundaryContext == null) return;
      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return;

      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !renderObject.attached || !renderObject.hasSize) return;

      final dpr = MediaQuery.of(context).devicePixelRatio.clamp(1.0, 2.0);
      final snapshot = await renderObject.toImage(pixelRatio: dpr);
      if (!mounted) {
        snapshot.dispose();
        return;
      }
      final previous = _lastGpuSnapshot;
      setState(() {
        _lastGpuSnapshot = snapshot;
      });
      previous?.dispose();
    } catch (_) {
      // Best effort only.
    }
  }

  Future<ui.Image?> _captureProbeImage(
    RenderRepaintBoundary boundary, {
    double pixelRatio = 0.10,
  }) async {
    if (!mounted || !boundary.attached) return null;
    if (!boundary.hasSize || boundary.size.isEmpty) return null;

    // Ensure a painted frame exists before reading from the layer.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !boundary.attached) return null;
    if (!boundary.hasSize || boundary.size.isEmpty) return null;

    try {
      return await boundary
          .toImage(pixelRatio: pixelRatio)
          .timeout(const Duration(milliseconds: 250));
    } catch (e) {
      if (e.toString().contains('Null check operator used on a null value')) {
        _log.warn('gpu', 'Health check skipped: boundary image not ready');
        return null;
      }
      rethrow;
    }
  }

  void _scheduleGpuHealthCheck() {
    _gpuHealthTimer?.cancel();
    if (RuntimeModeService.useRendererPlaceholderSurface) {
      return;
    }
    _gpuHealthTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      if (_compareMode) return;
      if (_backendDecision.backend == RendererBackend.cpu) return;

      _gpuProbeActive = true;
      _gpuProbeBackendSwitches = 0;
      if (kDebugMode) {
        debugPrint('[renderer] gpu_health_probe start');
      }

      final controller = context.read<FractalController>();
      if (controller.module.dimension != FractalDimension.twoD) {
        if (kDebugMode) {
          debugPrint(
              '[renderer] gpu_health_probe skipped reason=non_2d_module');
        }
        _gpuProbeActive = false;
        return;
      }

      final boundaryContext = _fractalKeyA.currentContext;
      if (boundaryContext == null) {
        _log.warn('gpu',
            'Health check skipped: no boundary context (renderer not mounted?)');
        if (kDebugMode) {
          debugPrint(
              '[renderer] gpu_health_probe skipped reason=no_boundary_context');
        }
        _gpuProbeActive = false;
        return;
      }
      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        _log.warn('gpu', 'Health check skipped: no RenderRepaintBoundary');
        if (kDebugMode) {
          debugPrint(
              '[renderer] gpu_health_probe skipped reason=no_repaint_boundary');
        }
        _gpuProbeActive = false;
        return;
      }

      ui.Image? imgA;
      ui.Image? imgB;
      try {
        // IMPORTANT: health probe must NOT mutate live controller params.

        // Take two low-res snapshots for robustness, but without changing any
        // params (no transient iteration bumps).
        imgA = await _captureProbeImage(renderObject);
        if (imgA == null) return;
        final dataA = await imgA.toByteData(format: ImageByteFormat.rawRgba);
        if (dataA == null) return;

        await Future<void>.delayed(const Duration(milliseconds: 220));

        imgB = await _captureProbeImage(renderObject);
        if (imgB == null) return;
        final dataB = await imgB.toByteData(format: ImageByteFormat.rawRgba);
        if (dataB == null) return;

        final width = imgB.width;
        final height = imgB.height;

        // We only care about black/near-black output and histogram sanity here.
        // Progression checks (frameProgressed/iterationDeltaVisible) were tied
        // to the old iteration-bump approach and are intentionally ignored.
        final stats = validateRenderFrame(
          frame: dataB.buffer.asUint8List(),
          width: width,
          height: height,
        );

        _lastGpuNonBlackRatio = stats.nonBlackRatio;
        _lastGpuDarkRatio = 1.0 - stats.nonBlackRatio;
        _lastGpuCenterNonBlack = stats.centerNonBlack;
        _lastGpuHistogramSane = stats.histogramSane;
        _lastGpuSampleCount = width * height;
        final probeFailed = _forceGpuHealthProbeFailure ||
            !stats.centerNonBlack ||
            !stats.histogramSane;
        if (probeFailed) {
          _gpuHealthFailureStreak++;
        } else {
          _gpuHealthFailureStreak = 0;
        }
        // Require two consecutive probe failures before forcing CPU fallback.
        // In deterministic simulation mode we force failover in a single probe.
        final requiredFailureStreak = _forceGpuHealthProbeFailure ? 1 : 2;
        _gpuHealthFailed = _gpuHealthFailureStreak >= requiredFailureStreak;

        _log.logState(
            'gpu',
            'GPU health check',
            {
              'pass': !_gpuHealthFailed,
              'probeFailed': probeFailed,
              'failureStreak': _gpuHealthFailureStreak,
              'nonBlackRatio': stats.nonBlackRatio,
              'centerNonBlack': stats.centerNonBlack,
              'histogramSane': stats.histogramSane,
              'sampleCount': width * height,
              'backendSwitchesDuringProbe': _gpuProbeBackendSwitches,
              'forcedProbeFailure': _forceGpuHealthProbeFailure,
            },
            level: _gpuHealthFailed ? LogLevel.warn : LogLevel.info);

        // Force one decision refresh after probe. If GPU is healthy, this should
        // not cause any backend switch.
        _refreshBackendDecision();

        debugPrint(stats.summary('gpu'));
        final moduleId = controller.module.id;
        debugPrint(
          '[renderer] gpu_health module=$moduleId nonBlackRatio=${stats.nonBlackRatio.toStringAsFixed(3)} centerNonBlack=${stats.centerNonBlack} histogramSane=${stats.histogramSane} sampleCount=${width * height} backendSwitchesDuringProbe=$_gpuProbeBackendSwitches forcedProbeFailure=$_forceGpuHealthProbeFailure',
        );

        // Extra diagnostic line: proves we did not trigger backend switches while probing.
        debugPrint(
          '[renderer] gpu_health_probe side_effects backendSwitchesDuringProbe=$_gpuProbeBackendSwitches (expected 0 on healthy GPU)',
        );

        // Keep old API behavior: we still captured two frames, even though we
        // now validate from a single frame. (Avoid unused var warnings.)
        // ignore: unused_local_variable
        final _ = dataA;
      } catch (e) {
        _lastGpuHealthError = e;
        if (e is TimeoutException) {
          if (kDebugMode) {
            debugPrint(
                '[renderer] gpu_health_probe skipped reason=to_image_timeout');
          }
        } else {
          _log.error('gpu', 'Health check error',
              data: {'error': e.toString()});
        }
      } finally {
        imgA?.dispose();
        imgB?.dispose();
        _gpuProbeActive = false;
      }
    });
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

  FractalController _activeController(BuildContext context) {
    if (_compareMode && _activePane == 1 && _compareController != null) {
      return _compareController!;
    }
    return context.read<FractalController>();
  }

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

  Future<void> _shareGpuDebugReport(BuildContext context) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    try {
      // Build payload first (share_plus seems unreliable on some Samsung builds without ADB).
      final payload = <String, Object?>{
        'timestamp': DateTime.now().toIso8601String(),
        'moduleId': controller.module.id,
        'moduleDimension': controller.module.dimension.name,
        'rendererPreference':
            context.read<RendererSettingsService>().backendMode.name,
        'backendDecision': {
          'backend': _backendDecision.backend.name,
          'reasonCode': _backendDecision.reasonToken,
          'detail': _backendDecision.detail,
        },
        'gpuHealthCheckEnabled': true,
        'lastGpuNonBlackRatio': _lastGpuNonBlackRatio,
        'lastGpuDarkRatio': _lastGpuDarkRatio,
        'lastGpuCenterNonBlack': _lastGpuCenterNonBlack,
        'lastGpuHistogramSane': _lastGpuHistogramSane,
        'lastGpuSampleCount': _lastGpuSampleCount,
        'lastGpuHealthError': _lastGpuHealthError?.toString(),
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };

      final reportText = const JsonEncoder.withIndent('  ').convert(payload);

      // Best-effort save the report + screenshot to the app export directory.
      final ts = DateTime.now().millisecondsSinceEpoch;
      final reportFile = await _exportService.saveBytes(
        Uint8List.fromList(reportText.codeUnits),
        filename: 'gpu_debug_${controller.module.id}_$ts.json',
      );

      File? screenshotFile;
      try {
        final png = await _exportService.capturePng(_activeBoundaryKey(),
            pixelRatio: 1.0);
        screenshotFile = await _exportService.saveBytes(
          png,
          filename: _exportService.generateFilename(
              prefix: 'gpu_debug',
              format: ExportFormat.png,
              fractalType: controller.module.id),
        );
      } catch (_) {
        // Screenshot capture can fail when GPU output is black; still continue with text report.
      }

      // Show an in-app sheet so the user can copy/paste the JSON into Telegram manually.
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPU Debug Report',
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ShaderLabScreen()),
                            );
                          },
                          icon: const Icon(Icons.science_rounded,
                              color: Colors.amber),
                          label: const Text('Open Shader Lab',
                              style: TextStyle(color: Colors.amber)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved report: ${reportFile.path}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (screenshotFile != null)
                    Text(
                      'Saved screenshot: ${screenshotFile.path}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        reportText,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: reportText));
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Copied GPU debug JSON to clipboard. Paste it into Telegram.')),
                          );
                        },
                        child: const Text('Copy JSON'),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportFailed(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

  void _pauseAutoExploreForExportSheet() {
    final svc = _autoExploreService;
    if (svc == null) {
      _resumeAutoExploreAfterExportSheet = false;
      return;
    }

    _resumeAutoExploreAfterExportSheet = svc.isExploring && !svc.isPaused;
    if (_resumeAutoExploreAfterExportSheet) {
      svc.pause();
    }
  }

  void _resumeAutoExploreAfterExportSheetIfNeeded() {
    final svc = _autoExploreService;
    if (svc == null) return;

    if (_resumeAutoExploreAfterExportSheet && svc.isExploring && svc.isPaused) {
      svc.resume();
    }
    _resumeAutoExploreAfterExportSheet = false;
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

  void _openExport(BuildContext context) {
    _log.info('action', 'Open export');
    final controller = _activeController(context);
    _pauseAutoExploreForExportSheet();
    setState(() {
      _freezeFrameForExport = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportOptionsSheet(
        initialOptions: const ExportOptions(),
        fractalType: controller.module.id,
        onExport: (options, action) => _performExport(
          context,
          options,
          shareAfterSave: action == ExportAction.saveAndShare,
        ),
      ),
    ).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _freezeFrameForExport = false;
      });
      _resumeAutoExploreAfterExportSheetIfNeeded();
    });
  }

  // ignore: unused_element
  void _openVideoExport(BuildContext context) {
    final controller = context.read<FractalController>();

    // Build available parameters for parameter sweep
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

  Future<void> _performVideoExport(
      BuildContext context, VideoExportOptions options) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });

    const videoService = const VideoExportService();
    final startView = controller.view;
    final startParams = Map<String, Object>.from(controller.params);

    try {
      final result = await videoService.exportVideo(
        options: options,
        startView: startView,
        startParams: startParams,
        fractalType: controller.module.id,
        updateView: (view, params) {
          // Update the fractal controller to the new view/params
          controller.updateZoom(view.zoom);
          controller.updatePan(view.pan);
          controller.updateRotation(view.rotation);
          if (params != null) {
            for (final entry in params.entries) {
              controller.updateParam(entry.key, entry.value);
            }
          }
        },
        captureFrame: () async {
          // Wait for the frame to render
          await Future.delayed(const Duration(milliseconds: 50));
          return await videoService.captureWidget(_activeBoundaryKey(),
              pixelRatio: 2.0);
        },
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _exportProgress = progress;
            });
          }
        },
      );

      // Restore original view and params
      controller.updateZoom(startView.zoom);
      controller.updatePan(startView.pan);
      controller.updateRotation(startView.rotation);
      for (final entry in startParams.entries) {
        controller.updateParam(entry.key, entry.value);
      }

      if (mounted) {
        // Share the video file
        await _exportService.shareFile(result.file,
            text: l10n.videoExportTitle);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.videoExportComplete),
                      Text(
                        '${result.resolution} • ${result.format.displayName} • ${result.formattedSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Restore original view and params on error
      controller.updateZoom(startView.zoom);
      controller.updatePan(startView.pan);
      controller.updateRotation(startView.rotation);
      for (final entry in startParams.entries) {
        controller.updateParam(entry.key, entry.value);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.videoExportFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }

  Future<void> _applyWallpaper(
      BuildContext context, WallpaperOptions options) async {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final dpr = mq.devicePixelRatio;

    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });

    try {
      // Export at *physical* device resolution.
      final exportOptions = ExportOptions(
        format: ExportFormat.png,
        resolution: ExportResolution.custom,
        customWidth: (size.width * dpr).round(),
        customHeight: (size.height * dpr).round(),
        embedMetadata: false,
      );

      final bytes = await _exportService.captureWithOptions(
        _activeBoundaryKey(),
        options: exportOptions,
        screenWidth: size.width,
        screenHeight: size.height,
        onProgress: (p) {
          if (!mounted) return;
          // Keep within the same overlay UI used for export.
          setState(() => _exportProgress = p * 0.9);
        },
      );

      final styledBytes = _exportService.applyWallpaperStyle(
        bytes,
        style: options.style.name,
      );

      // Apply wallpaper (Android) or save to Photos (iOS).
      final ok = await _wallpaperService.setWallpaper(
        styledBytes,
        target: options.target,
      );

      if (options.saveCopy) {
        final filename = _exportService.generateFilename(
          prefix: 'wallpaper',
          format: ExportFormat.png,
          fractalType: controller.module.id,
        );
        final file =
            await _exportService.saveBytes(styledBytes, filename: filename);
        // Count saved wallpaper copy as a screenshot/export.
        context.read<ExplorationStatsService?>()?.recordScreenshot();
        // Best-effort share sheet so users can move it to Files/Photos.
        await _exportService.shareFile(file, text: l10n.wallpaperTitle);
      }

      if (mounted) {
        await HapticService.heavy();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? l10n.wallpaperApplied : l10n.wallpaperFailed),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wallpaperFailedWithError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }

  Future<void> _performExport(
    BuildContext context,
    ExportOptions options, {
    required bool shareAfterSave,
  }) async {
    final controller = _activeController(context);
    final boundaryKey = _activeBoundaryKey();
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final previousTransparency = controller.transparentBackground;

    setState(() {
      _exporting = true;
      _exportProgress = 0;
    });

    try {
      // Set transparency if requested
      if (options.transparentBackground) {
        controller.setTransparentBackground(true);
        // Wait for the widget to repaint
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Perform the export
      final result = await _exportService.exportWithOptions(
        boundaryKey,
        options: options,
        screenWidth: size.width,
        screenHeight: size.height,
        fractalType: controller.module.id,
        parameters: controller.params,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _exportProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        // Heavy haptic feedback on export complete
        await HapticService.heavy();

        // Count as a screenshot/export
        context.read<ExplorationStatsService?>()?.recordScreenshot();

        // Optional share to installed apps.
        if (shareAfterSave) {
          await _exportService.shareFile(result.file, text: l10n.exportTitle);
        }

        // Show success message with details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.exportSaved),
                      Text(
                        '${result.resolution} • ${result.format.displayName} • ${result.formattedSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      // Restore transparency setting
      controller.setTransparentBackground(previousTransparency);
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportProgress = null;
        });
      }
    }
  }
}
