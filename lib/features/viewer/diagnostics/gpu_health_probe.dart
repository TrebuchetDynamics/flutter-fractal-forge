import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/backend_policy.dart';
import 'package:flutter_fractals/features/renderer/precision_ladder_policy.dart';
import 'package:flutter_fractals/features/renderer/render_plan.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';

/// Result of a single GPU health frame evaluation.
@immutable
class GpuProbeFrameResult {
  final bool healthFailed;
  final bool probeFailed;
  final int failureStreak;
  final double nonBlackRatio;
  final bool centerNonBlack;
  final bool histogramSane;
  final int sampleCount;

  const GpuProbeFrameResult({
    required this.healthFailed,
    required this.probeFailed,
    required this.failureStreak,
    required this.nonBlackRatio,
    required this.centerNonBlack,
    required this.histogramSane,
    required this.sampleCount,
  });
}

/// Side-effect hints returned by [GpuHealthProbe.decide] for the mixin to act on.
@immutable
class GpuBackendUpdate {
  /// True when a GPU→CPU transition was committed; the mixin must capture a
  /// GPU snapshot before the CPU renderer takes over.
  final bool captureSnapshot;

  const GpuBackendUpdate({required this.captureSnapshot});

  static const none = GpuBackendUpdate(captureSnapshot: false);
}

/// Owns all GPU health-probe and backend-decision state.
///
/// Testable without a widget tree: callers supply platform flags, mode, and
/// frame data; this class owns failure-streak counting, hysteresis gating, and
/// the backend-decision state machine. Widget-coupled concerns (timers, image
/// capture, setState) remain in the mixin.
class GpuHealthProbe {
  static const bool _defaultForceProbeFailure = bool.fromEnvironment(
    'FORCE_GPU_HEALTH_PROBE_FAILURE',
    defaultValue: false,
  );

  final RendererPlanPolicy _renderPlanPolicy;
  final PrecisionLadderHysteresis _precisionLadderHysteresis;
  final PrecisionLadderPolicy _precisionLadderPolicy;
  final AppLogger _log;
  final bool _forceProbeFailure;

  bool _gpuHealthFailed = false;
  bool _isAndroidEmulator = false;
  int _gpuHealthFailureStreak = 0;
  bool _gpuProbeActive = false;
  int _gpuProbeBackendSwitches = 0;

  BackendDecision _backendDecision = const BackendDecision(
    backend: RendererBackend.gpu,
    reasonCode: FallbackReasonCode.none,
    detail: 'init',
  );
  DateTime? _lastBackendSwitch;
  String? _lastBackendDecisionModuleId;

  bool _deepZoomPrecisionActive = false;
  PrecisionLadderDecision? _precisionDecisionCache;

  // Readable by the GPU debug report.
  double? lastGpuNonBlackRatio;
  double? lastGpuDarkRatio;
  bool? lastGpuCenterNonBlack;
  bool? lastGpuHistogramSane;
  int? lastGpuSampleCount;
  Object? lastGpuHealthError;

  GpuHealthProbe({
    RendererPlanPolicy? renderPlanPolicy,
    PrecisionLadderHysteresis? precisionLadderHysteresis,
    PrecisionLadderPolicy? precisionLadderPolicy,
    AppLogger? log,
    @visibleForTesting bool? forceProbeFailure,
  })  : _renderPlanPolicy = renderPlanPolicy ?? const RendererPlanPolicy(),
        _precisionLadderHysteresis =
            precisionLadderHysteresis ?? PrecisionLadderHysteresis(),
        _precisionLadderPolicy =
            precisionLadderPolicy ?? const PrecisionLadderPolicy(),
        _log = log ?? AppLogger.instance,
        _forceProbeFailure = forceProbeFailure ?? _defaultForceProbeFailure;

  // ── read-only state ──────────────────────────────────────────────────────────

  BackendDecision get backendDecision => _backendDecision;
  bool get deepZoomPrecisionActive => _deepZoomPrecisionActive;
  bool get gpuHealthFailed => _gpuHealthFailed;
  bool get isAndroidEmulator => _isAndroidEmulator;
  int get gpuProbeBackendSwitches => _gpuProbeBackendSwitches;

  @visibleForTesting
  bool get isForceProbeFailure => _forceProbeFailure;

  // ── precision ladder ─────────────────────────────────────────────────────────

  PrecisionLadderDecision currentPrecisionDecision(
    FractalController controller,
  ) {
    final cached = _precisionDecisionCache;
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

  void refreshPrecision(FractalController controller) {
    final decision = _precisionLadderHysteresis.update(
      moduleId: controller.module.id,
      dimension: controller.module.dimension,
      zoom: controller.view.zoom,
    );
    _precisionDecisionCache = decision;
    _deepZoomPrecisionActive = decision.showPrecisionIndicator;
  }

  RendererPlan rendererPlan(FractalController controller) => RendererPlan(
        precision: currentPrecisionDecision(controller),
        backend: _backendDecision,
      );

  // ── backend decision ─────────────────────────────────────────────────────────

  /// Recomputes the backend decision from caller-supplied context values.
  ///
  /// Returns a [GpuBackendUpdate] telling the mixin whether to capture a GPU
  /// snapshot. All state mutation and backend-switch logging happen here.
  GpuBackendUpdate decide({
    required RendererBackendMode mode,
    required String moduleId,
    required bool isAndroid,
    required bool isWeb,
    required FractalController controller,
  }) {
    final precision = currentPrecisionDecision(controller);
    final oldBackend = _backendDecision.backend;
    final moduleChanged = _lastBackendDecisionModuleId != moduleId;

    final newDecision = _renderPlanPolicy
        .decide(
          precision: precision,
          userMode: mode,
          gpuHealthFailed: _gpuHealthFailed,
          isAndroid: isAndroid,
          isWeb: isWeb,
          isEmulator: _isAndroidEmulator,
        )
        .backend;

    if (newDecision.backend == oldBackend) {
      _backendDecision = newDecision;
      _lastBackendDecisionModuleId = moduleId;
      return GpuBackendUpdate.none;
    }

    final now = DateTime.now();
    final lastSwitch = _lastBackendSwitch;
    final switchAllowed = moduleChanged ||
        lastSwitch == null ||
        now.difference(lastSwitch).inMilliseconds >= 500;

    if (!switchAllowed) {
      _lastBackendDecisionModuleId = moduleId;
      return GpuBackendUpdate.none;
    }

    final captureSnapshot = oldBackend == RendererBackend.gpu &&
        newDecision.backend == RendererBackend.cpu;

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
    _lastBackendDecisionModuleId = moduleId;

    return GpuBackendUpdate(captureSnapshot: captureSnapshot);
  }

  // ── probe lifecycle ──────────────────────────────────────────────────────────

  void beginProbe() {
    _gpuProbeActive = true;
    _gpuProbeBackendSwitches = 0;
  }

  /// Evaluates captured frame data and updates failure-streak + health state.
  ///
  /// Call after [beginProbe] and frame capture. Always call [endProbe] in a
  /// finally block regardless of whether this succeeds.
  GpuProbeFrameResult evaluateFrame({
    required Uint8List frameData,
    required int width,
    required int height,
  }) {
    final stats = validateRenderFrame(
      frame: frameData,
      width: width,
      height: height,
    );

    lastGpuNonBlackRatio = stats.nonBlackRatio;
    lastGpuDarkRatio = 1.0 - stats.nonBlackRatio;
    lastGpuCenterNonBlack = stats.centerNonBlack;
    lastGpuHistogramSane = stats.histogramSane;
    lastGpuSampleCount = width * height;

    final probeFailed =
        _forceProbeFailure || !stats.centerNonBlack || !stats.histogramSane;
    if (probeFailed) {
      _gpuHealthFailureStreak++;
    } else {
      _gpuHealthFailureStreak = 0;
    }
    final required = _forceProbeFailure ? 1 : 2;
    _gpuHealthFailed = _gpuHealthFailureStreak >= required;

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
        'forcedProbeFailure': _forceProbeFailure,
      },
      level: _gpuHealthFailed ? LogLevel.warn : LogLevel.info,
    );

    return GpuProbeFrameResult(
      healthFailed: _gpuHealthFailed,
      probeFailed: probeFailed,
      failureStreak: _gpuHealthFailureStreak,
      nonBlackRatio: stats.nonBlackRatio,
      centerNonBlack: stats.centerNonBlack,
      histogramSane: stats.histogramSane,
      sampleCount: width * height,
    );
  }

  void endProbe() {
    _gpuProbeActive = false;
  }

  void recordProbeError(Object error) {
    lastGpuHealthError = error;
  }

  // ── health reset ─────────────────────────────────────────────────────────────

  /// Clears the GPU health failure flag and failure streak.
  ///
  /// Call when the active module changes or when the user explicitly requests
  /// a GPU retry, so the next probe starts from a clean slate.
  void resetHealth() {
    _gpuHealthFailed = false;
    _gpuHealthFailureStreak = 0;
  }

  void setAndroidEmulator(bool value) => _isAndroidEmulator = value;
}
