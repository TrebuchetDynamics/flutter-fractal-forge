import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
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
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/history/history_sheet.dart';
import 'package:flutter_fractals/features/presets/preset_sheet.dart';
import 'package:flutter_fractals/features/minimap/fractal_minimap.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/wallpaper/wallpaper_options_sheet.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Forces the CPU fallback renderer.
///
/// Useful for emulator CI runs and for validating gesture paths.
/// Enable with: --dart-define=FORCE_CPU_FALLBACK=true
const bool kForceCpuFallback =
    bool.fromEnvironment('FORCE_CPU_FALLBACK', defaultValue: false);

class FractalViewerScreen extends StatefulWidget {
  const FractalViewerScreen({Key? key}) : super(key: key);

  @override
  State<FractalViewerScreen> createState() => _FractalViewerScreenState();
}

class _FractalViewerScreenState extends State<FractalViewerScreen>
    with TickerProviderStateMixin {
  // Widget tests run with a stripped-down engine; treat those runs as "test"
  // so we can exercise renderer-dependent UI even when real GPU features are disabled.
  static final bool _isTest = (() {
    var v = false;
    assert(() {
      v = true;
      return true;
    }());
    return v || const bool.fromEnvironment('FLUTTER_TEST');
  })();

  final GlobalKey _fractalKeyA = GlobalKey();
  final GlobalKey _fractalKeyB = GlobalKey();
  final ExportService _exportService = const ExportService();
  final WallpaperService _wallpaperService = const WallpaperService();

  // Compare mode state
  bool _compareMode = false;
  bool _compareSliderMode = false; // false: side-by-side, true: sliding divider
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
  bool _showShaderDebug = false;

  // CPU fallback if GPU shader output appears black.
  bool _useCpuFallback = false;
  // Disable the heuristic that auto-switches to CPU fallback.
  // Useful for debugging device-specific GPU issues.
  bool _disableGpuHealthCheck = true; // DIAG: disabled to test GPU rendering
  double? _lastGpuDarkRatio;
  int? _lastGpuSampleCount;
  Object? _lastGpuHealthError;
  Timer? _gpuHealthTimer;

  // History tracking
  FractalController? _lastController;

  // Exploration stats tracking
  ExplorationStatsService? _statsService;
  DateTime? _sessionStart;
  double? _lastZoom;
  String? _lastModuleId;

  // Auto-explore service
  AutoExploreService? _autoExploreService;

  // Freeze renderer while export sheet is open.
  bool _freezeFrameForExport = false;
  bool _resumeAutoExploreAfterExportSheet = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    )..forward();
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

      // Schedule GPU health check for this module.
      // Note: in emulator/CI we can force CPU fallback to make tests deterministic.
      _useCpuFallback = kForceCpuFallback;
      if (!_useCpuFallback) {
        _scheduleGpuHealthCheck();
      }

      // Initialize auto-explore service
      _autoExploreService?.dispose();
      _autoExploreService = AutoExploreService(controller: controller);
    }
  }

  void _scheduleGpuHealthCheck() {
    _gpuHealthTimer?.cancel();
    if (_disableGpuHealthCheck) return;
    // Give shader load + first frames a moment.
    _gpuHealthTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      if (_compareMode) return; // skip in compare mode for now
      if (_useCpuFallback) return;
      if (_disableGpuHealthCheck) return;

      final controller = context.read<FractalController>();
      if (controller.module.dimension != FractalDimension.twoD) {
        return; // CPU fallback currently only for 2D
      }

      final boundaryContext = _fractalKeyA.currentContext;
      if (boundaryContext == null) return;
      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return;

      try {
        // Render a tiny snapshot to check if the canvas is basically black.
        final img = await renderObject.toImage(pixelRatio: 0.05);
        final data = await img.toByteData(format: ImageByteFormat.rawRgba);
        if (data == null) return;

        final bytes = data.buffer.asUint8List();
        // Sample every Nth pixel.
        int count = 0;
        int dark = 0;
        for (int i = 0; i + 3 < bytes.length; i += 4 * 40) {
          final r = bytes[i];
          final g = bytes[i + 1];
          final b = bytes[i + 2];
          // luminance approx
          final lum = (0.2126 * r + 0.7152 * g + 0.0722 * b);
          if (lum < 8) dark++;
          count++;
        }
        if (count > 0) {
          final darkRatio = dark / count;
          _lastGpuDarkRatio = darkRatio;
          _lastGpuSampleCount = count;
          if (darkRatio > 0.98) {
            if (mounted) {
              setState(() {
                _useCpuFallback = true;
              });
            }
          }
        }
      } catch (e) {
        _lastGpuHealthError = e;
        // Ignore snapshot failures.
      }
    });
  }

  void _onControllerChanged() {
    if (!mounted) return;

    // If module changed, reset fallback + re-check.
    final controller = context.read<FractalController>();
    if (_lastModuleId != null && _lastModuleId != controller.module.id) {
      _useCpuFallback = kForceCpuFallback;
      if (!_useCpuFallback) {
        _scheduleGpuHealthCheck();
      }
    }

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
      _lastModuleId = currentId;
      _statsService?.recordFractalExplored(currentId);
    }
  }

  @override
  void dispose() {
    _gpuHealthTimer?.cancel();
    _lastController?.removeListener(_onControllerChanged);

    final start = _sessionStart;
    if (start != null) {
      final elapsed = DateTime.now().difference(start);
      _statsService?.addExploreTime(elapsed);
    }

    _fabController.dispose();
    _debugRunner?.dispose();
    _performanceService.dispose();
    _autoExploreService?.dispose();
    _compareController?.dispose();
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

  void _toggleCompareMode(BuildContext context) {
    setState(() {
      _compareMode = !_compareMode;
      if (_compareMode) {
        _ensureCompareController(context);
        _activePane = 0;
      }
    });
  }

  void _toggleCompareLayout() {
    setState(() {
      _compareSliderMode = !_compareSliderMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final l10n = AppLocalizations.of(context)!;

    if (_compareMode) {
      _ensureCompareController(context);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _PremiumViewerAppBar(
        title: controller.module.displayName(l10n),
        onBack: () => Navigator.of(context).pop(),
        actions: [
          if (kDebugMode)
            _AppBarIconButton(
              icon: Icons.bug_report_rounded,
              tooltip: 'GPU debug report',
              onPressed: () => _shareGpuDebugReport(context),
            ),
          _AppBarIconButton(
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
          // Compare (A/B) intentionally removed from user-facing UI.

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
                    ? _CompareRenderer(
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
                        freezeFrame: _freezeFrameForExport,
                      )
                    : (_useCpuFallback
                        ? _CpuFallbackPane(boundaryKey: _fractalKeyA)
                        : ((controller.module.dimension ==
                                    FractalDimension.threeD) &&
                                !_isTest
                            ? const Center(
                                child: Text(
                                  '3D fractals are disabled on this device.\n(Mandelbulb shader load stalls.)',
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : FractalRenderer(
                                boundaryKey: _fractalKeyA,
                                animationEnabled: !_freezeFrameForExport,
                                onOpenControls: () => _openControls(context),
                                onOpenPresets: () => _openPresets(context),
                                onOpenExport: () => _openExport(context),
                              ))),
              ),

              if (_useCpuFallback)
                Positioned(
                  // Avoid overlapping the ShaderDebugOverlay which is positioned at top:80, left:8.
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: _CpuFallbackBanner(
                      onTryGpu: () {
                        setState(() {
                          _useCpuFallback = false;
                          // Keep the health-check disabled so we can see the raw GPU output.
                          _disableGpuHealthCheck = true;
                        });
                      },
                      onReport: () => _shareGpuDebugReport(context),
                    ),
                  ),
                ),

              // Minimap overlay (bottom-left)
              Positioned(
                left: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                child: ChangeNotifierProvider.value(
                  value: _activeController(context),
                  child: FractalMiniMap(viewportSize: viewportSize),
                ),
              ),

              // Floating action buttons
              Positioned(
                right: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                child: FadeTransition(
                  opacity: _fabController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.5, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _fabController,
                      curve: AppAnimations.defaultCurve,
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Auto-explore button
                        if (_autoExploreService != null)
                          ChangeNotifierProvider<AutoExploreService>.value(
                            value: _autoExploreService!,
                            child: AutoExploreButton(
                              delay: const Duration(milliseconds: 0),
                              onLongPress: _exporting
                                  ? null
                                  : () => _openAutoExploreSettings(context),
                            ),
                          ),
                        if (_autoExploreService != null)
                          const SizedBox(height: AppSpacing.md),
                        // Keep the viewer uncluttered: only core actions here.
                        _FloatingActionButton(
                          icon: Icons.tune_rounded,
                          tooltip: l10n.tooltipOpenControls,
                          onPressed:
                              _exporting ? null : () => _openControls(context),
                          delay: const Duration(milliseconds: 50),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _FloatingActionButton(
                          icon: Icons.bookmark_rounded,
                          tooltip: l10n.tooltipOpenPresets,
                          onPressed:
                              _exporting ? null : () => _openPresets(context),
                          delay: const Duration(milliseconds: 100),
                        ),
                        // AR entry is in the app bar to avoid redundant buttons.

                        const SizedBox(height: AppSpacing.md),
                        _FloatingActionButton(
                          icon: Icons.download_rounded,
                          tooltip: l10n.tooltipExport,
                          onPressed:
                              _exporting ? null : () => _openExport(context),
                          isPrimary: true,
                          delay: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Export progress overlay
              if (_exporting)
                Positioned.fill(
                  child: _ExportOverlay(
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
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
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
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 48,
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
            ],
          );
        },
      ),
    );
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
        'cpuFallbackActive': _useCpuFallback,
        'gpuHealthCheckDisabled': _disableGpuHealthCheck,
        'lastGpuDarkRatio': _lastGpuDarkRatio,
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
                      'Saved screenshot: ${screenshotFile!.path}',
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

  void _openControls(BuildContext context) {
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

  /// Shares the current fractal configuration via deep link.
  void _shareFractal(BuildContext context) {
    final controller = _activeController(context);
    final l10n = AppLocalizations.of(context)!;

    // Build the deep link URL
    final uri = DeepLinkService.buildUri(
      moduleId: controller.module.id,
      params: controller.params,
      view: controller.view,
    );

    // Show a bottom sheet with sharing options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(
        uri: uri,
        fractalName: controller.module.displayName(l10n),
      ),
    );
  }

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

    final videoService = const VideoExportService();
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

class _CpuFallbackBanner extends StatelessWidget {
  final VoidCallback onTryGpu;
  final VoidCallback onReport;

  const _CpuFallbackBanner({
    required this.onTryGpu,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CPU fallback enabled (GPU output appeared black).',
            style: TextStyle(color: Colors.amber, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onTryGpu,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.6)),
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Text('Try GPU'),
              ),
              OutlinedButton(
                onPressed: onReport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: BorderSide(color: Colors.amber.withOpacity(0.8)),
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Text('Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CpuFallbackPane extends StatefulWidget {
  final GlobalKey boundaryKey;

  const _CpuFallbackPane({required this.boundaryKey});

  @override
  State<_CpuFallbackPane> createState() => _CpuFallbackPaneState();
}

class _CpuFallbackPaneState extends State<_CpuFallbackPane> {
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final module = controller.module;

    if (module.dimension != FractalDimension.twoD) {
      return const Center(
        child: Text(
          '3D fractals are disabled on this device.\n(Mandelbulb shader load stalls.)',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    final state = FractalRenderState(
      params: controller.params,
      view: controller.view,
      transparentBackground: controller.transparentBackground,
    );

    final content = RepaintBoundary(
      key: widget.boundaryKey,
      child: CpuFractalRenderer(
        module: module,
        state: state,
      ),
    );

    // Basic gesture support for CPU fallback.
    return GestureDetector(
      onScaleStart: (_) {
        _lastScale = 1.0;
      },
      onScaleUpdate: (details) {
        // Pan with one-finger drag (focalPointDelta) + zoom with pinch.
        if (details.focalPointDelta != Offset.zero) {
          final dx = details.focalPointDelta.dx;
          final dy = details.focalPointDelta.dy;
          // Map pixels to complex-plane movement.
          final s = (0.004 / controller.view.zoom).clamp(0.00001, 0.1);
          controller.updatePan(
            Vector2(
              controller.view.pan.x - dx * s,
              controller.view.pan.y - dy * s,
            ),
          );
        }

        final scaleDelta = details.scale / _lastScale;
        if (scaleDelta.isFinite && (scaleDelta - 1.0).abs() > 0.001) {
          controller.updateZoom(
              (controller.view.zoom * scaleDelta).clamp(0.05, 20000.0));
        }
        _lastScale = details.scale;
      },
      child: content,
    );
  }
}

class _CompareRenderer extends StatelessWidget {
  final GlobalKey keyA;
  final GlobalKey keyB;
  final FractalController controllerB;
  final bool sliderMode;
  final double divider;
  final int activePane;
  final ValueChanged<double> onDividerChanged;
  final ValueChanged<int> onActivePaneChanged;
  final VoidCallback onOpenControls;
  final VoidCallback onOpenPresets;
  final VoidCallback onOpenExport;
  final bool freezeFrame;

  const _CompareRenderer({
    required this.keyA,
    required this.keyB,
    required this.controllerB,
    required this.sliderMode,
    required this.divider,
    required this.activePane,
    required this.onDividerChanged,
    required this.onActivePaneChanged,
    required this.onOpenControls,
    required this.onOpenPresets,
    required this.onOpenExport,
    required this.freezeFrame,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.read<FractalController>();

    Widget paneA = _ComparePane(
      isActive: activePane == 0,
      label: 'A',
      onTap: () => onOpenPane(0),
      child: ChangeNotifierProvider.value(
        value: a,
        child: FractalRenderer(
          boundaryKey: keyA,
          animationEnabled: !freezeFrame,
          gesturesEnabled: activePane == 0,
          onOpenControls: onOpenControls,
          onOpenPresets: onOpenPresets,
          onOpenExport: onOpenExport,
        ),
      ),
    );

    Widget paneB = _ComparePane(
      isActive: activePane == 1,
      label: 'B',
      onTap: () => onOpenPane(1),
      child: ChangeNotifierProvider.value(
        value: controllerB,
        child: FractalRenderer(
          boundaryKey: keyB,
          animationEnabled: !freezeFrame,
          gesturesEnabled: activePane == 1,
          onOpenControls: onOpenControls,
          onOpenPresets: onOpenPresets,
          onOpenExport: onOpenExport,
        ),
      ),
    );

    if (!sliderMode) {
      return Row(
        children: [
          Expanded(child: paneA),
          Container(width: 1, color: AppColors.surfaceVariant.withOpacity(0.6)),
          Expanded(child: paneB),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final clamped = divider.clamp(0.05, 0.95);
        final x = width * clamped;

        return Stack(
          children: [
            Positioned.fill(child: paneA),
            Positioned.fill(
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1.0 - clamped,
                  child: paneB,
                ),
              ),
            ),
            Positioned(
              left: x - 18,
              top: 0,
              bottom: 0,
              width: 36,
              child: _CompareDividerHandle(
                onDrag: (dx) {
                  final next = (x + dx) / width;
                  onDividerChanged(next.clamp(0.05, 0.95));
                },
                onTapLeft: () => onOpenPane(0),
                onTapRight: () => onOpenPane(1),
              ),
            ),
          ],
        );
      },
    );
  }

  void onOpenPane(int pane) {
    onActivePaneChanged(pane);
  }
}

class _ComparePane extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _ComparePane({
    required this.child,
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: 12,
            top: MediaQuery.of(context).padding.top + 12,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.primary : AppColors.surfaceVariant)
                    .withOpacity(0.65),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(isActive ? 0.35 : 0.15),
                ),
              ),
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (isActive)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.35),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompareDividerHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  const _CompareDividerHandle({
    required this.onDrag,
    required this.onTapLeft,
    required this.onTapRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
      onTapUp: (details) {
        final localX = details.localPosition.dx;
        if (localX < 18) {
          onTapLeft();
        } else {
          onTapRight();
        }
      },
      child: Center(
        child: Container(
          width: 28,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.drag_handle_rounded,
              color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _PremiumViewerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final List<Widget> actions;

  const _PremiumViewerAppBar({
    required this.title,
    required this.onBack,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withOpacity(0.9),
                AppColors.background.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.xs),
                  _AnimatedBackButton(onPressed: onBack),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FadeIn(
                      child: Text(
                        title,
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    ...actions,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedBackButton({required this.onPressed});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticService.medium();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FloatingActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Duration delay;

  const _FloatingActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isPrimary = false,
    this.delay = Duration.zero,
  });

  @override
  State<_FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<_FloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for reduced motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return FadeIn(
      delay: reduceMotion ? Duration.zero : widget.delay,
      child: Semantics(
        label: widget.tooltip,
        button: true,
        enabled: widget.onPressed != null,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTapDown: (widget.onPressed != null && !reduceMotion)
                ? (_) {
                    setState(() => _isPressed = true);
                    _controller.forward();
                    HapticService.medium();
                  }
                : null,
            onTapUp: (widget.onPressed != null && !reduceMotion)
                ? (_) {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  }
                : null,
            onTapCancel: (widget.onPressed != null && !reduceMotion)
                ? () {
                    setState(() => _isPressed = false);
                    _controller.reverse();
                  }
                : null,
            onTap: widget.onPressed,
            child: reduceMotion
                ? _buildButtonContent()
                : ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildButtonContent(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: widget.isPrimary ? AppColors.primaryGradient : null,
        color: widget.isPrimary ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: widget.isPrimary
            ? null
            : Border.all(
                color: _isPressed
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.border.withOpacity(0.5),
              ),
        boxShadow: [
          BoxShadow(
            color: widget.isPrimary
                ? AppColors.primary.withOpacity(_isPressed ? 0.5 : 0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: _isPressed ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: 22,
        color: widget.isPrimary
            ? Colors.white
            : (_isPressed ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}

class _ExportOverlay extends StatelessWidget {
  final double? progress;
  final AppLocalizations l10n;

  const _ExportOverlay({
    required this.progress,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withOpacity(0.7),
        child: Center(
          child: FadeIn(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.xl),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.downloading_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.exporting,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                        if (progress != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${(progress! * 100).round()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for sharing fractal configuration via deep link.
class _ShareSheet extends StatelessWidget {
  final Uri uri;
  final String fractalName;

  const _ShareSheet({
    required this.uri,
    required this.fractalName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final linkText = uri.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                l10n.shareTitle,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.shareSubtitle(fractalName),
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Link preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        linkText,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Share buttons
              Row(
                children: [
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.copy_rounded,
                      label: l10n.actionCopy,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: linkText));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_rounded,
                                    color: AppColors.success, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Text(l10n.linkCopied),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ShareButton(
                      icon: Icons.share_rounded,
                      label: l10n.actionShare,
                      isPrimary: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Share.share(
                          l10n.shareMessage(fractalName, linkText),
                          subject: l10n.shareSubject(fractalName),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticService.medium();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? AppColors.primaryGradient : null,
            color: widget.isPrimary ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: AppColors.border.withOpacity(0.3),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  color:
                      widget.isPrimary ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
