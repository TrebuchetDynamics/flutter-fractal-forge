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
import 'package:vector_math/vector_math_64.dart' show Vector2;
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/wallpaper/wallpaper_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/diagnostics/debug_runner_service.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/looper_mp4_encoder.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_worker.dart';
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
import 'package:flutter_fractals/core/services/storage/viewer_session_store.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
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
import 'package:flutter_fractals/features/fourier/lab/fractal_uncertainty_lab_screen.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_analysis_backend.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_analysis_controller.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_backend_lease.dart';
import 'package:flutter_fractals/features/fourier/services/fourier_offscreen_renderer.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_settings_sheet.dart';
import 'package:flutter_fractals/features/fourier/widgets/fourier_spectrum_view.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_scan_overlay.dart';
import 'package:flutter_fractals/features/viewer/audio/fractal_music_service.dart';
import 'package:flutter_fractals/features/viewer/audio/fourier_music_features.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_session.dart';
import 'package:flutter_fractals/features/viewer/overlays/auto_pilot_alignment_overlay.dart';
import 'package:flutter_fractals/features/viewer/diagnostics/gpu_health_probe.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_fractals/shared/widgets/app_feedback_snack_bar.dart';

part 'diagnostics/viewer_gpu_health.dart';
part 'diagnostics/viewer_debug_report.dart';
part 'dialogs/viewer_dialogs.dart';
part 'export/viewer_export_actions.dart';
part 'navigation/viewer_interactions.dart';
part 'navigation/viewer_history.dart';
part 'overlays/viewer_hud.dart';

/// Display label for a report tag.
///
/// The tag string itself stays English on purpose: it is written verbatim into
/// the saved report's JSON, which a maintainer reads, so translating it would
/// change the report's data rather than only its presentation. Only what the
/// sheet shows is localized. An unrecognised tag falls back to its own text,
/// so adding one to FractalReportService.defaultTags cannot render blank.
String _reportTagLabel(AppLocalizations l10n, String tag) {
  switch (tag) {
    case 'Low performance':
      return l10n.reportTagLowPerformance;
    case 'Weak deep zoom':
      return l10n.reportTagWeakDeepZoom;
    case 'Low detail':
      return l10n.reportTagLowDetail;
    case 'No image':
      return l10n.reportTagNoImage;
    case 'Bad initial view':
      return l10n.reportTagBadInitialView;
    case 'Bad default params':
      return l10n.reportTagBadDefaultParams;
    case 'Needs more Control Params':
      return l10n.reportTagNeedsMoreControlParams;
    case 'Randomize breaks':
      return l10n.reportTagRandomizeBreaks;
    case 'Remove candidate':
      return l10n.reportTagRemoveCandidate;
    case 'Bad thumbnail':
      return l10n.reportTagBadThumbnail;
    case 'Wrong fractal':
      return l10n.reportTagWrongFractal;
    case 'Missing shader':
      return l10n.reportTagMissingShader;
    case 'Other':
      return l10n.reportTagOther;
    default:
      return tag;
  }
}

typedef FourierAnalysisBackendFactory = Future<FourierAnalysisBackend>
    Function();

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

  /// Export/share backend, overridable so tests can drive the flows that depend
  /// on it.
  ///
  /// Saving, sharing, wallpaper and the GPU debug report all run through this,
  /// and each begins with a directory picker and real file writes. With the
  /// service constructed inline none of those surfaces could be rendered in a
  /// test, so the debug report sheet in particular was audited by reading it
  /// rather than by measuring it. Defaults to the real service.
  final ExportService? exportService;

  /// Platform wallpaper backend, overridable for the same reason.
  final WallpaperService? wallpaperService;

  /// Whether this route may apply an interrupted viewer snapshot.
  ///
  /// Launch deep links pass false because their explicit state must take
  /// precedence over any stale process-restoration snapshot.
  final bool restoreViewerSession;

  /// Worker seam used by lifecycle tests; production uses one isolate backend.
  final FourierAnalysisBackendFactory fourierBackendFactory;

  const FractalViewerScreen({
    Key? key,
    this.captureMode = false,
    this.catalogFamily = CatalogFamily.core,
    this.exportService,
    this.wallpaperService,
    this.restoreViewerSession = true,
    this.fourierBackendFactory = IsolateFourierAnalysisBackend.spawn,
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
  ExportService get _exportService =>
      widget.exportService ?? const ExportService();
  @override
  WallpaperService get _wallpaperService =>
      widget.wallpaperService ?? const WallpaperService();
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
  bool _fourierEnabled = false;
  bool _fourierMusicEnabled = false;
  bool _fourierApplyHann = true;
  bool _fourierRemoveDc = true;
  FourierDisplayMode _fourierDisplayMode = FourierDisplayMode.split;
  FourierResolution _fourierResolution = FourierResolution.auto;
  FourierAnalysisController? _fourierController;
  final FourierBackendLease _fourierBackendLease = FourierBackendLease();
  final FourierOffscreenRenderer _fourierOffscreenRenderer =
      FourierOffscreenRenderer();
  final FractalRenderSnapshotSink _fourierRenderSnapshotSink =
      FractalRenderSnapshotSink();
  Timer? _fourierCaptureTimer;
  ui.Image? _fourierSpectrumImage;
  int _fourierGeneration = 0;
  int _displayedFourierGeneration = -1;
  int _loggedFourierAttemptGeneration = -1;
  bool _fourierCaptureInFlight = false;
  int _fourierCaptureSession = 0;
  DateTime? _lastFourierCaptureAt;
  final FourierMusicFeatureSmoother _fourierMusicSmoother =
      FourierMusicFeatureSmoother();
  final FourierMusicDecisionController _fourierMusicDecisionController =
      FourierMusicDecisionController();
  FourierMusicFeatures? _currentFourierMusicFeatures;

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
  ViewerSessionStore? _viewerSessionStore;
  bool _viewerSessionRestored = false;
  bool _viewerSessionRestorePending = false;

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
      scanProgress: () => _musicScanController.value,
      currentFourierFeatures: () =>
          _fourierMusicEnabled ? _currentFourierMusicFeatures : null,
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
    if (state != AppLifecycleState.resumed) {
      _persistViewerSession();
    }
    final visible = state == AppLifecycleState.resumed;
    if (_appVisible == visible) return;
    if (!visible) {
      _fourierCaptureTimer?.cancel();
      _fourierCaptureTimer = null;
    }
    setState(() {
      _appVisible = visible;
    });
    if (visible && _fourierEnabled && _fourierController != null) {
      _startFourierCaptureTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_captureFourierFrame());
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewerSessionStore ??= context.read<ViewerSessionStore?>();
    final controller = context.read<FractalController>();
    if (!_viewerSessionRestored && widget.restoreViewerSession) {
      _viewerSessionRestored = true;
      _restoreViewerSession(controller);
    }
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
    if (_lastController != controller) {
      _lastController?.removeListener(_onControllerChanged);
      _lastController = controller;

      _sessionTracker!.attach(controller);

      controller.addListener(_onControllerChanged);
      // Record initial state unless an interrupted session is still being
      // applied after this frame.
      if (!_viewerSessionRestorePending) {
        _recordHistory(context);
      }

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
      if (!_viewerSessionRestorePending) {
        _persistViewerSession();
      }
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
    if (_viewerSessionRestorePending) {
      _refreshPrecisionDecision(controller);
      _refreshBackendDecision();
      return;
    }
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
    _musicCoordinator.scheduleRescan(
      controller,
      moduleChanged: moduleChanged,
    );
    if (_fourierEnabled) {
      unawaited(_captureFourierFrame(throttled: true));
    }

    if (moduleChanged) {
      _log.logState('action', 'Module changed', {
        'from': prevModuleId,
        'to': controller.module.id,
      });
    }

    _sessionTracker?.onControllerChanged(controller);
    _persistViewerSession();
  }

  void _restoreViewerSession(FractalController controller) {
    final snapshot = _viewerSessionStore?.load();
    if (snapshot == null || !snapshot.viewerActive) return;
    _showControlsHud = snapshot.controlsVisible;
    _fullscreenUnobtrusive = snapshot.fullscreenUnobtrusive;
    _viewerSessionRestorePending = true;
    try {
      snapshot.applyToController(controller, notifyListeners: false);
    } on Object {
      unawaited(_viewerSessionStore?.markViewerInactive());
    } finally {
      _viewerSessionRestorePending = false;
    }
  }

  void _persistViewerSession() {
    final store = _viewerSessionStore;
    final controller = _lastController;
    if (store == null || controller == null) return;
    unawaited(store.save(ViewerSessionSnapshot(
      moduleId: controller.module.id,
      params: controller.params,
      view: controller.view,
      transparentBackground: controller.transparentBackground,
      rotationLocked: controller.rotationLocked,
      glowEnabled: controller.glowEnabled,
      glowSigma: controller.glowSigma,
      glowIntensity: controller.glowIntensity,
      fluidModeEnabled: controller.fluidModeEnabled,
      fluidStrength: controller.fluidStrength,
      kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
      kaleidoscopeSectors: controller.kaleidoscopeSectors,
      kaleidoscopeMirror: controller.kaleidoscopeMirror,
      kaleidoscopeRotation: controller.kaleidoscopeRotation,
      kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode,
      controlsVisible: _showControlsHud,
      fullscreenUnobtrusive: _fullscreenUnobtrusive,
      viewerActive: true,
    )));
  }

  @override
  void dispose() {
    unawaited(
        _viewerSessionStore?.markViewerInactive() ?? Future<void>.value());
    WidgetsBinding.instance.removeObserver(this);
    _gpuHealthTimer?.cancel();
    _backendDebounceTimer?.cancel();
    _fourierBackendLease.invalidate();
    _fourierCaptureTimer?.cancel();
    _fourierController?.removeListener(_onFourierAnalysisChanged);
    _fourierController?.dispose();

    _fourierSpectrumImage?.dispose();
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
    _persistViewerSession();
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
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TextOverlayEditorSheet(initialText: _textOverlay.text),
    );
    if (text == null) return;

    setState(() => _textOverlay.applyEdit(text));
    await _textOverlay.save();
  }

  @override
  String? get _activeQuoteText => _textOverlay.activeQuoteText;

  Future<void> _toggleFractalMusic() async {
    final controller = _activeController(context);
    final enabling = !_viewerEffects.fractalMusicEnabled;
    if (!enabling) {
      // Invalidate decoder/upload work immediately; the serialized stop still
      // follows, but a candidate can no longer take ownership after the tap.
      _musicCoordinator.cancelRescan();
    }
    final scanFrame = enabling ? await _captureFractalMusicScanFrame() : null;
    final result = await _viewerEffects.toggleFractalMusic(
      controller,
      scanFrame: scanFrame,
      fourierFeatures:
          _fourierMusicEnabled ? _currentFourierMusicFeatures : null,
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

  @override
  Future<FractalMusicScanFrame?> captureFractalMusicScanFrame() =>
      _captureFractalMusicScanFrame();

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

  Future<void> _toggleFourier() async {
    if (_fourierEnabled) {
      _disableFourier();
      return;
    }
    _fourierCaptureSession++;
    final activationGeneration = _fourierBackendLease.begin();
    setState(() => _fourierEnabled = true);
    try {
      final backend = await _fourierBackendLease.acquire(
        generation: activationGeneration,
        factory: widget.fourierBackendFactory,
        isActive: () => mounted && _fourierEnabled,
      );
      if (backend == null) return;
      final controller = FourierAnalysisController(backend: backend)
        ..addListener(_onFourierAnalysisChanged);
      _log.debug('fourier', 'Analysis worker ready');
      setState(() => _fourierController = controller);
      _startFourierCaptureTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_captureFourierFrame());
      });
      AccessibilityService.announce(
        AppLocalizations.of(context)?.tooltipFourierOn ?? 'Fourier view on',
      );
    } catch (error) {
      if (!mounted) return;
      _log.debug('fourier', 'Analysis worker activation failed',
          data: {'error': '$error'});
      _disableFourier();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.fourierUnavailable ??
                'Fourier analysis unavailable',
          ),
        ),
      );
    }
  }

  void _disableFourier() {
    _fourierCaptureSession++;
    _fourierBackendLease.invalidate();
    _fourierCaptureTimer?.cancel();
    _fourierCaptureTimer = null;
    final controller = _fourierController;
    controller?.removeListener(_onFourierAnalysisChanged);
    controller?.dispose();
    _fourierController = null;
    _fourierCaptureInFlight = false;
    _displayedFourierGeneration = -1;
    final image = _fourierSpectrumImage;
    _fourierSpectrumImage = null;
    image?.dispose();
    _fourierMusicEnabled = false;
    _clearFourierMusicModulation();
    if (mounted) setState(() => _fourierEnabled = false);
  }

  void _startFourierCaptureTimer() {
    _fourierCaptureTimer?.cancel();
    if (!_appVisible || !_fourierEnabled || _fourierController == null) return;
    _fourierCaptureTimer = Timer.periodic(
      const Duration(milliseconds: 450),
      (_) => unawaited(_captureFourierFrame()),
    );
  }

  void _clearFourierMusicModulation() {
    final hadFeatures = _currentFourierMusicFeatures != null;
    _fourierMusicSmoother.reset();
    _fourierMusicDecisionController.reset();
    _currentFourierMusicFeatures = null;
    if (hadFeatures &&
        mounted &&
        _viewerEffects.fractalMusicEnabled &&
        _lastController != null) {
      _musicCoordinator.cancelRescan();
      _musicCoordinator.scheduleRescan(_lastController!);
    }
  }

  Future<ui.Image?> _captureBoundaryAfterPaint(
    GlobalKey boundaryKey,
    double pixelRatio,
    int captureSession,
  ) {
    final completer = Completer<ui.Image?>();
    var remainingAttempts = 4;

    void attempt(Duration _) {
      if (captureSession != _fourierCaptureSession ||
          !mounted ||
          !_fourierEnabled ||
          !_appVisible) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary ||
          !renderObject.attached ||
          !renderObject.hasSize) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      if (renderObject.debugNeedsPaint && remainingAttempts-- > 0) {
        WidgetsBinding.instance.addPostFrameCallback(attempt);
        WidgetsBinding.instance.scheduleFrame();
        return;
      }
      if (renderObject.debugNeedsPaint) {
        completer.completeError(StateError('analysis boundary stayed dirty'));
        return;
      }
      try {
        renderObject.toImage(pixelRatio: pixelRatio).then(
              completer.complete,
              onError: completer.completeError,
            );
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback(attempt);
    WidgetsBinding.instance.scheduleFrame();
    return completer.future.timeout(const Duration(seconds: 2));
  }

  Future<void> _captureFourierFrame({bool throttled = false}) async {
    final captureSession = _fourierCaptureSession;
    final controller = _fourierController;
    if (!_fourierEnabled ||
        !_appVisible ||
        controller == null ||
        controller.processing ||
        _fourierCaptureInFlight) {
      return;
    }
    final now = DateTime.now();
    if (throttled &&
        _lastFourierCaptureAt != null &&
        now.difference(_lastFourierCaptureAt!) <
            const Duration(milliseconds: 250)) {
      return;
    }
    _fourierCaptureInFlight = true;
    _lastFourierCaptureAt = now;
    bool isCurrentCapture() =>
        captureSession == _fourierCaptureSession &&
        mounted &&
        _fourierEnabled &&
        _appVisible;
    try {
      if (!isCurrentCapture()) return;
      ui.Image? image;
      if (_backendDecision.backend == RendererBackend.gpu) {
        final snapshot = _fourierRenderSnapshotSink.snapshot;
        if (snapshot == null) {
          if (!isCurrentCapture()) return;
          _clearFourierMusicModulation();
          return;
        }
        final targetDimension = _fourierResolution.pixels ?? 128;
        final screen = MediaQuery.sizeOf(context);
        final landscape = screen.width > screen.height;
        final paneWidth =
            _fourierDisplayMode == FourierDisplayMode.split && landscape
                ? screen.width / 2
                : screen.width;
        final paneHeight =
            _fourierDisplayMode == FourierDisplayMode.split && !landscape
                ? screen.height / 2
                : screen.height;
        final width = paneWidth >= paneHeight
            ? targetDimension
            : math.max(8, (targetDimension * paneWidth / paneHeight).round());
        final height = paneHeight > paneWidth
            ? targetDimension
            : math.max(8, (targetDimension * paneHeight / paneWidth).round());
        image = await _fourierOffscreenRenderer.render(
          snapshot: snapshot,
          width: width,
          height: height,
        );
      } else {
        final pixelRatio = switch (_fourierResolution) {
          FourierResolution.pixels256 => 0.5,
          _ => 0.25,
        };
        image = await _captureBoundaryAfterPaint(
          _activeBoundaryKey(),
          pixelRatio,
          captureSession,
        );
      }
      if (image == null) {
        if (!isCurrentCapture()) return;
        _clearFourierMusicModulation();
        return;
      }
      try {
        if (!isCurrentCapture()) return;
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (!isCurrentCapture()) return;
        if (data == null) {
          _clearFourierMusicModulation();
          return;
        }
        final generation = ++_fourierGeneration;
        _log.debug('fourier', 'Submitting viewport spectrum', data: {
          'generation': generation,
          'width': image.width,
          'height': image.height,
        });
        controller.submit(
          FourierWorkerRequest(
            generation: generation,
            rgba: Uint8List.fromList(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            ),
            width: image.width,
            height: image.height,
            maxDimension: _fourierResolution.pixels ?? 128,
            removeDc: _fourierRemoveDc,
            applyHann: _fourierApplyHann,
          ),
        );
      } finally {
        image.dispose();
      }
    } catch (error) {
      if (isCurrentCapture()) {
        _clearFourierMusicModulation();
        _log.debug('fourier', 'Viewport capture failed',
            data: {'error': '$error'});
      }
    } finally {
      if (captureSession == _fourierCaptureSession) {
        _fourierCaptureInFlight = false;
      }
    }
  }

  void _onFourierAnalysisChanged() {
    final analysisController = _fourierController;
    final result = analysisController?.result;
    final attempt = analysisController?.latestAttempt;
    if (attempt != null &&
        attempt.generation > _loggedFourierAttemptGeneration) {
      _loggedFourierAttemptGeneration = attempt.generation;
      _log.debug('fourier', 'Analysis attempt complete', data: {
        'generation': attempt.generation,
        'blank': attempt.blank,
        'elapsedMicroseconds': attempt.elapsedMicroseconds,
        'captureMean': attempt.features.captureMean,
        'captureVariance': attempt.features.captureVariance,
        'alphaCoverage': attempt.features.alphaCoverage,
      });
    }
    if (analysisController?.error case final error?) {
      _log.debug('fourier', 'Analysis failed', data: {'error': '$error'});
      _clearFourierMusicModulation();
    }
    if (attempt != null &&
        attempt.blank &&
        attempt.generation > (result?.generation ?? -1)) {
      _clearFourierMusicModulation();
    }
    if (!mounted ||
        result == null ||
        result.generation <= _displayedFourierGeneration) {
      if (mounted) setState(() {});
      return;
    }
    _displayedFourierGeneration = result.generation;
    _log.debug('fourier', 'Analysis complete', data: {
      'generation': result.generation,
      'blank': result.blank,
      'elapsedMicroseconds': result.elapsedMicroseconds,
      'width': result.width,
      'height': result.height,
    });
    if (_fourierMusicEnabled && !result.blank) {
      final measured = result.features;
      final mapped = const FourierMusicFeatureMapper().map(
        FourierMusicSpectrumFrame(
          lowPowerRatio: measured.lowPowerRatio,
          midPowerRatio: measured.midPowerRatio,
          highPowerRatio: measured.highPowerRatio,
          centroid: measured.centroid,
          entropy: measured.entropy,
          flatness: measured.flatness,
          orientation: measured.dominantOrientation,
          anisotropy: measured.orientationStrength,
          spectralFlux: measured.spectralFlux,
        ),
      );
      final smoothed = _fourierMusicSmoother.update(mapped);
      final decisions = _fourierMusicDecisionController.update(
        smoothed,
        isBarBoundary: true,
      );
      final next = FourierMusicFeatures(
        bassWeight: smoothed.bassWeight,
        padOpenness: smoothed.padOpenness,
        highTexture: smoothed.highTexture,
        leadRegister: decisions.registerBand.index / 2,
        rhythmicComplexity: decisions.rhythmDensity.index / 2,
        stereoBias: smoothed.stereoBias,
        transitionStrength: smoothed.transitionStrength,
        orientation: smoothed.orientation,
        anisotropy: smoothed.anisotropy,
        isSilent: smoothed.isSilent,
      );
      final previous = _currentFourierMusicFeatures;
      _currentFourierMusicFeatures = next;
      if (_viewerEffects.fractalMusicEnabled &&
          _fourierMusicDiffers(previous, next)) {
        _musicCoordinator.scheduleRescan(
          _activeController(context),
          alignToBar: true,
        );
      }
    }
    ui.decodeImageFromPixels(
      result.spectrumRgba,
      result.width,
      result.height,
      ui.PixelFormat.rgba8888,
      (image) {
        if (!mounted ||
            !_fourierEnabled ||
            result.generation != _displayedFourierGeneration) {
          image.dispose();
          return;
        }
        final previous = _fourierSpectrumImage;
        setState(() => _fourierSpectrumImage = image);
        previous?.dispose();
      },
    );
  }

  bool _fourierMusicDiffers(
    FourierMusicFeatures? previous,
    FourierMusicFeatures next,
  ) {
    if (previous == null || previous.isSilent != next.isSilent) return true;
    final before = previous.normalizedValues;
    final after = next.normalizedValues;
    for (var index = 0; index < before.length; index++) {
      if ((before[index] - after[index]).abs() >= 0.04) return true;
    }
    return (previous.stereoBias - next.stereoBias).abs() >= 0.08;
  }

  Future<void> _openFourierSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          void update(VoidCallback change) {
            setState(change);
            setSheetState(() {});
            if (_fourierEnabled) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                unawaited(_captureFourierFrame());
              });
            }
          }

          return FourierSettingsSheet(
            displayMode: _fourierDisplayMode,
            resolution: _fourierResolution,
            applyHann: _fourierApplyHann,
            removeDc: _fourierRemoveDc,
            fourierMusicEnabled: _fourierMusicEnabled,
            onDisplayModeChanged: (value) =>
                update(() => _fourierDisplayMode = value),
            onResolutionChanged: (value) =>
                update(() => _fourierResolution = value),
            onApplyHannChanged: (value) =>
                update(() => _fourierApplyHann = value),
            onRemoveDcChanged: (value) =>
                update(() => _fourierRemoveDc = value),
            onFourierMusicChanged: (value) {
              update(() {
                _fourierMusicEnabled = value;
                if (!value) {
                  _fourierMusicSmoother.reset();
                  _currentFourierMusicFeatures = null;
                }
              });
              if (_viewerEffects.fractalMusicEnabled) {
                _musicCoordinator.scheduleRescan(_activeController(context));
              }
            },
            onOpenUncertaintyLab: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FractalUncertaintyLabScreen(),
                ),
              );
            },
          );
        },
      ),
    );
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
    _persistViewerSession();
  }

  void _handleViewerBack(bool didPop) {
    if (didPop) return;
    if (_exporting) {
      _exportService.cancelActiveExport();
      return;
    }
    if (_showControlsHud) {
      setState(() => _showControlsHud = false);
      _persistViewerSession();
      return;
    }
    if (_fullscreenUnobtrusive && !widget.captureMode) {
      _toggleFullscreenUnobtrusive();
    }
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
        builder: (context, setSheetState) => AppBottomSheet(
          maxHeightFactor: 0.66,
          children: [
            AppBottomSheetHeader(
              icon: Icons.report_problem_rounded,
              iconGradient: const LinearGradient(
                colors: [AppColors.warning, Color(0xFFFF7A45)],
              ),
              title: l10n.reportDialogTitle,
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
                      l10n.reportDialogNotes,
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
                        hintText: l10n.reportDialogNotesHint,
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
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.reportDialogSymptoms,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.reportDialogSymptomsHint,
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
                            label: _reportTagLabel(l10n, tag),
                            selected: selected.contains(tag),
                            onTap: () => setSheetState(() {
                              if (!selected.remove(tag)) selected.add(tag);
                            }),
                          ),
                      ],
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
                      child: Text(l10n.buttonCancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () => Navigator.of(sheetContext).pop(true),
                      child: Text(l10n.reportDialogSave),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          builder: (dialogContext) => AppDialog(
            icon: Icons.data_object_rounded,
            title: l10n.reportDialogCopyJsonTitle,
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(child: SelectableText(json)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionClose),
              ),
              FilledButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: json));
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.reportDialogCopiedJson)),
                    );
                  }
                },
                child: Text(l10n.actionCopy),
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
        SnackBar(content: Text(l10n.fractalReportSaved(file.path))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        appFeedbackSnackBar(
          message: l10n.fractalReportFailed(error.toString()),
          success: false,
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

    final current = controller.params['colorScheme'];
    final selectedIndex =
        options.indexWhere((option) => option.value == current);
    const columnCount = 4;
    final gridWidth = MediaQuery.sizeOf(context).width -
        AppSpacing.md * 2 -
        AppSpacing.sm * (columnCount - 1);
    final tileWidth = math.max(1.0, gridWidth / columnCount);
    final selectedRow = math.max(0, selectedIndex ~/ columnCount - 1);
    final paletteScrollController = ScrollController(
      initialScrollOffset: selectedRow * (tileWidth / 0.86 + AppSpacing.sm),
    );

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
                subtitle: l10n.palettePickerSubtitle,
                onClose: () => Navigator.of(context).pop(),
              ),
              Flexible(
                child: GridView.builder(
                  controller: paletteScrollController,
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
    ).whenComplete(paletteScrollController.dispose);
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
      _log.debug('renderer', 'Backend decision', data: {'decision': decision});
    }

    if (_compareMode) {
      _ensureCompareController(context);
    }

    final handlesBack = _exporting ||
        _showControlsHud ||
        (_fullscreenUnobtrusive && !widget.captureMode);
    return PopScope(
      canPop: !handlesBack,
      onPopInvokedWithResult: (didPop, result) => _handleViewerBack(didPop),
      child: Focus(
        autofocus: true,
        focusNode: _keyboardFocusNode,
        onKeyEvent: (node, event) => _onKeyEvent(context, event),
        child: Scaffold(
          key: const Key('fractalViewerRoot'),
          extendBody: true,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final activeController = _activeController(context);
              final landscape = constraints.maxWidth > constraints.maxHeight;
              final topInset = MediaQuery.of(context).padding.top;
              final overlayTop = topInset + 56;

              return Stack(
                children: [
                  // Fractal renderer (single or compare)
                  Positioned(
                    left: 0,
                    top: 0,
                    right: _fourierEnabled &&
                            _fourierDisplayMode == FourierDisplayMode.split &&
                            landscape
                        ? constraints.maxWidth / 2
                        : 0,
                    bottom: _fourierEnabled &&
                            _fourierDisplayMode == FourierDisplayMode.split &&
                            !landscape
                        ? constraints.maxHeight / 2
                        : 0,
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
                            activeSnapshotSink: _fourierRenderSnapshotSink,
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
                                renderSnapshotSink: _fourierRenderSnapshotSink,
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

                  if (_fourierEnabled)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _FourierPaneLabel(l10n.fourierSpatialPane),
                    ),

                  if (_fourierEnabled)
                    Positioned(
                      left: _fourierDisplayMode == FourierDisplayMode.split &&
                              landscape
                          ? constraints.maxWidth / 2
                          : 0,
                      top: _fourierDisplayMode == FourierDisplayMode.split &&
                              !landscape
                          ? constraints.maxHeight / 2
                          : 0,
                      right: 0,
                      bottom: 0,
                      child: AbsorbPointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FourierSpectrumView(
                                image: _fourierSpectrumImage,
                                features: _fourierController?.result?.features,
                                processing:
                                    _fourierController?.processing ?? true,
                                unavailable:
                                    _fourierController?.unavailable ?? false,
                              ),
                              Positioned(
                                left: 12,
                                top: 12,
                                child: _FourierPaneLabel(
                                  l10n.fourierSpectrumPane,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                      // Height-bounded and scrollable because the banner is a
                      // Positioned child: nothing clips or reports it, so at a
                      // 2x text scale in landscape its buttons sat 91px below
                      // the viewport and at 3x up to 343px below — silently
                      // untappable, taking "Try GPU" and "Report" with them.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 240,
                          maxHeight: math.max(
                              0, constraints.maxHeight - overlayTop - 12),
                        ),
                        child: SingleChildScrollView(
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
                  if (_showCoreViewerChrome &&
                      !_showControlsHud &&
                      _autoExploreService != null)
                    Positioned(
                      top: overlayTop,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom:
                          MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                      child: ChangeNotifierProvider<AutoExploreService>.value(
                        value: _autoExploreService!,
                        child: FractalViewControls(
                          fabController: _fabController,
                          isExporting: _exportFlowActive,
                          kaleidoscopeEnabled:
                              activeController.kaleidoscopeEnabled,
                          kaleidoscopeSectors:
                              activeController.kaleidoscopeSectors,
                          kaleidoscopeMirror:
                              activeController.kaleidoscopeMirror,
                          fractalMusicEnabled:
                              _viewerEffects.fractalMusicEnabled,
                          fourierEnabled: _fourierEnabled,
                          textOverlayEnabled: _textOverlay.enabled,
                          // Keep the GPU report affordance on desktop only;
                          // Android production viewers must not expose a
                          // debug/error FAB in the primary action rail.
                          showFractalReport: !kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.linux,
                          actions: FractalViewControlActions(
                            toggleFullscreen: _toggleFullscreenUnobtrusive,
                            openRandomFractal: () =>
                                _onRandomFractalFab(context),
                            openControls: () => _toggleControlsHud(),
                            randomizeParams: () {
                              HapticFeedback.mediumImpact();
                              final activeController =
                                  _activeController(context);
                              activeController.randomizeParams();
                            },
                            cycleColorScheme: () => _cycleColorScheme(context),
                            openPalettePicker: () =>
                                _openPalettePicker(context),
                            toggleKaleidoscope: () =>
                                _toggleKaleidoscope(context),
                            setKaleidoscopeSectors: (sectors) {
                              final activeController =
                                  _activeController(context);
                              activeController.setKaleidoscopeEnabled(true);
                              activeController.setKaleidoscopeSectors(sectors);
                            },
                            setKaleidoscopeMirror: (value) {
                              final activeController =
                                  _activeController(context);
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
                            toggleFourier: _toggleFourier,
                            openFourierSettings: _openFourierSettings,
                            reportFractal: () => _reportFractal(context),
                            openWallpaper: () => _openWallpaper(context),
                            openAutoExploreSettings: () =>
                                showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ChangeNotifierProvider<
                                  AutoExploreService>.value(
                                value: _autoExploreService!,
                                child: const AutoExploreSettingsSheet(),
                              ),
                            ),
                          ),
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
                        onCancel: _exportService.cancelActiveExport,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TextOverlayEditorSheet extends StatefulWidget {
  const _TextOverlayEditorSheet({required this.initialText});

  final String initialText;

  @override
  State<_TextOverlayEditorSheet> createState() =>
      _TextOverlayEditorSheetState();
}

class _TextOverlayEditorSheetState extends State<_TextOverlayEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBottomSheet(
      maxHeightFactor: 0.52,
      children: [
        AppBottomSheetHeader(
          icon: Icons.format_quote_rounded,
          title: l10n.textOverlayTitle,
          subtitle: l10n.textOverlaySubtitle,
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            key: const ValueKey('viewerTextOverlayField'),
            controller: _controller,
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text),
                  child: Text(l10n.actionApply),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final colorScheme = Theme.of(context).colorScheme;
    // Which palette is active is otherwise conveyed only by the check icon and
    // the border colour, so a screen reader hears nine identical buttons.
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.18)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
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
                              color: colorScheme.primary,
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
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      height: 1.05,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

  LinearGradient _paletteGradient(Object value) {
    if (value is num) {
      try {
        final palette = PaletteService.instance.paletteAtIndex(value.round());
        final colors =
            palette.stops.map((stop) => Color(stop.colorArgb)).toList();
        if (colors.length >= 2) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
            stops: palette.stops.map((stop) => stop.position).toList(),
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

class _FourierPaneLabel extends StatelessWidget {
  const _FourierPaneLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      );
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
