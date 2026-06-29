part of '../fractal_viewer_screen.dart';

/// Mixin that owns all GPU health-probe and backend-decision state and logic.
///
/// Apply to `State<FractalViewerScreen>`.
mixin _GpuHealthMixin on State<FractalViewerScreen> {
  static const bool _forceGpuHealthProbeFailure = bool.fromEnvironment(
    'FORCE_GPU_HEALTH_PROBE_FAILURE',
    defaultValue: false,
  );
  static const int _emuProbeTimeoutMs = int.fromEnvironment(
    'EMU_PROBE_TIMEOUT_MS',
    defaultValue: 250,
  );

  // Abstract members satisfied by _FractalViewerScreenState.
  AppLogger get _log;
  GlobalKey get _fractalKeyA;
  bool get _compareMode;

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
  final RendererPlanPolicy _renderPlanPolicy = const RendererPlanPolicy();
  BackendDecision _backendDecision = const BackendDecision(
    backend: RendererBackend.gpu,
    reasonCode: FallbackReasonCode.none,
    detail: 'init',
  );
  ui.Image? _lastGpuSnapshot;
  DateTime? _lastBackendSwitch;
  String? _lastBackendDecisionModuleId;

  // Deep-zoom precision indicator + hysteresis filter
  // (avoids rapid GPU↔CPU flicker when zooming near the threshold)
  bool _deepZoomPrecisionActive = false;
  final PrecisionLadderPolicy _precisionLadderPolicy =
      const PrecisionLadderPolicy();
  final PrecisionLadderHysteresis _precisionLadderHysteresis =
      PrecisionLadderHysteresis();
  PrecisionLadderDecision? _precisionDecision;

  PrecisionLadderDecision _currentPrecisionDecision(
    FractalController controller,
  ) {
    final cached = _precisionDecision;
    if (cached != null &&
        cached.moduleId == controller.module.id &&
        cached.dimension == controller.module.dimension &&
        cached.zoom == controller.view.zoom) {
      return cached;
    }
    return _precisionLadderPolicy.decide(
      moduleId: controller.module.id,
      dimension: controller.module.dimension,
      zoom: controller.view.zoom,
    );
  }

  void _refreshPrecisionDecision(FractalController controller) {
    final decision = _precisionLadderHysteresis.update(
      moduleId: controller.module.id,
      dimension: controller.module.dimension,
      zoom: controller.view.zoom,
    );
    _precisionDecision = decision;
    _deepZoomPrecisionActive = decision.showPrecisionIndicator;
  }

  RendererPlan _currentRendererPlan(FractalController controller) =>
      RendererPlan(
        precision: _currentPrecisionDecision(controller),
        backend: _backendDecision,
      );

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

    final precisionDecision = _currentPrecisionDecision(controller);

    final newDecision = _renderPlanPolicy
        .decide(
          precision: precisionDecision,
          userMode: mode,
          gpuHealthFailed: _gpuHealthFailed,
          isAndroid: !kIsWeb && Platform.isAndroid,
          isWeb: kIsWeb,
          isEmulator: _isAndroidEmulator,
        )
        .backend;

    if (newDecision.backend == oldBackend) {
      // Same backend: refresh reason/detail immediately. No switch side-effects.
      _backendDecision = newDecision;
      _lastBackendDecisionModuleId = currentModuleId;
      return;
    }

    // Backend differs. Hysteresis prevents rapid CPU<->GPU flip-flopping on the
    // same module: module switches apply immediately, otherwise wait 500ms since
    // the last applied switch.
    final now = DateTime.now();
    final lastSwitch = _lastBackendSwitch;
    final switchAllowed = moduleChanged ||
        lastSwitch == null ||
        now.difference(lastSwitch).inMilliseconds >= 500;

    if (!switchAllowed) {
      // Suppressed to prevent flicker: keep the old decision and fire NO switch
      // side-effects. Previously the snapshot/log/probe-counter ran on every
      // suppressed candidate, spamming expensive GPU snapshots and inflating the
      // "expected 0 switches on healthy GPU" probe metric near a threshold.
      _lastBackendDecisionModuleId = currentModuleId;
      return;
    }

    // Switch is actually being applied — run the switch side-effects now.
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

    _backendDecision = newDecision;
    _lastBackendSwitch = now;
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
      final timeoutMs = (_isAndroidEmulator && _emuProbeTimeoutMs > 250)
          ? _emuProbeTimeoutMs
          : 250;
      return await boundary
          .toImage(pixelRatio: pixelRatio)
          .timeout(Duration(milliseconds: timeoutMs));
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

        _refreshBackendDecision();

        if (kDebugMode) debugPrint(stats.summary('gpu'));
        final moduleId = controller.module.id;
        if (kDebugMode)
          debugPrint(
            '[renderer] gpu_health module=$moduleId nonBlackRatio=${stats.nonBlackRatio.toStringAsFixed(3)} centerNonBlack=${stats.centerNonBlack} histogramSane=${stats.histogramSane} sampleCount=${width * height} backendSwitchesDuringProbe=$_gpuProbeBackendSwitches forcedProbeFailure=$_forceGpuHealthProbeFailure',
          );
        if (kDebugMode)
          debugPrint(
            '[renderer] gpu_health_probe side_effects backendSwitchesDuringProbe=$_gpuProbeBackendSwitches (expected 0 on healthy GPU)',
          );

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
}
