part of '../fractal_viewer_screen.dart';

/// Mixin that coordinates GPU health-probe widget concerns: timer lifecycle,
/// image capture, and setState. All decision state lives in [GpuHealthProbe].
///
/// Apply to `State<FractalViewerScreen>`.
mixin _GpuHealthMixin on State<FractalViewerScreen> {
  static const int _emuProbeTimeoutMs = int.fromEnvironment(
    'EMU_PROBE_TIMEOUT_MS',
    defaultValue: 250,
  );

  // Abstract members satisfied by _FractalViewerScreenState.
  AppLogger get _log;
  GlobalKey get _fractalKeyA;
  bool get _compareMode;

  final GpuHealthProbe _gpuProbe = GpuHealthProbe();

  Timer? _gpuHealthTimer;

  // Widget-owned snapshot for CpuFallbackPane.
  ui.Image? _lastGpuSnapshot;

  // Delegate read-only state to the probe so build() and debug report can read
  // through the same names they used before.
  BackendDecision get _backendDecision => _gpuProbe.backendDecision;
  bool get _deepZoomPrecisionActive => _gpuProbe.deepZoomPrecisionActive;

  void _refreshPrecisionDecision(FractalController controller) =>
      _gpuProbe.refreshPrecision(controller);

  RendererPlan _currentRendererPlan(FractalController controller) =>
      _gpuProbe.rendererPlan(controller);

  Future<void> _detectEmulatorProfile() async {
    final isEmulator = await detectAndroidEmulator();
    if (!mounted) return;
    _log.logState(
        'lifecycle', 'Emulator detection', {'isEmulator': isEmulator});
    setState(() {
      _gpuProbe.setAndroidEmulator(isEmulator);
      _refreshBackendDecision();
    });
  }

  void _refreshBackendDecision() {
    final controller = context.read<FractalController>();
    final mode = context.read<RendererSettingsService>().backendMode;
    final update = _gpuProbe.decide(
      mode: mode,
      moduleId: controller.module.id,
      isAndroid: !kIsWeb && Platform.isAndroid,
      isWeb: kIsWeb,
      controller: controller,
    );
    if (update.captureSnapshot) unawaited(_captureLastGpuSnapshot());
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
      final timeoutMs =
          (_gpuProbe.isAndroidEmulator && _emuProbeTimeoutMs > 250)
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
      if (_gpuProbe.backendDecision.backend == RendererBackend.cpu) return;

      _gpuProbe.beginProbe();
      if (kDebugMode) debugPrint('[renderer] gpu_health_probe start');

      try {
        final controller = context.read<FractalController>();
        if (controller.module.dimension != FractalDimension.twoD) {
          if (kDebugMode) {
            debugPrint(
                '[renderer] gpu_health_probe skipped reason=non_2d_module');
          }
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
          return;
        }
        final renderObject = boundaryContext.findRenderObject();
        if (renderObject is! RenderRepaintBoundary) {
          _log.warn('gpu', 'Health check skipped: no RenderRepaintBoundary');
          if (kDebugMode) {
            debugPrint(
                '[renderer] gpu_health_probe skipped reason=no_repaint_boundary');
          }
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
          final dataA =
              await imgA.toByteData(format: ImageByteFormat.rawRgba);
          if (dataA == null) return;

          await Future<void>.delayed(const Duration(milliseconds: 220));

          imgB = await _captureProbeImage(renderObject);
          if (imgB == null) return;
          final dataB =
              await imgB.toByteData(format: ImageByteFormat.rawRgba);
          if (dataB == null) return;

          final width = imgB.width;
          final height = imgB.height;

          final result = _gpuProbe.evaluateFrame(
            frameData: dataB.buffer.asUint8List(),
            width: width,
            height: height,
          );

          _refreshBackendDecision();

          if (kDebugMode) {
            final moduleId = controller.module.id;
            debugPrint(
              '[renderer] gpu_health module=$moduleId'
              ' nonBlackRatio=${result.nonBlackRatio.toStringAsFixed(3)}'
              ' centerNonBlack=${result.centerNonBlack}'
              ' histogramSane=${result.histogramSane}'
              ' sampleCount=${result.sampleCount}'
              ' backendSwitchesDuringProbe=${_gpuProbe.gpuProbeBackendSwitches}',
            );
            debugPrint(
              '[renderer] gpu_health_probe side_effects'
              ' backendSwitchesDuringProbe=${_gpuProbe.gpuProbeBackendSwitches}'
              ' (expected 0 on healthy GPU)',
            );
          }

          // ignore: unused_local_variable
          final _ = dataA;
        } catch (e) {
          _gpuProbe.recordProbeError(e);
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
        }
      } finally {
        _gpuProbe.endProbe();
      }
    });
  }
}
