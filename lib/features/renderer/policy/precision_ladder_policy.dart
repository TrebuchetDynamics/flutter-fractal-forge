import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

const double _extendedGpuLowerZoom = 5e6;
const double _perturbationUpperZoom = 1e30;
const double _mandelbrotDf2UpperThreshold = 1e12;
const double _escapeTimeCpuFallbackThreshold = 1e9;
const double _defaultCpuFallbackThreshold = 1e7;

/// Renderer path selected by the deep-zoom precision ladder.
enum PrecisionLadderRenderPath {
  gpuFloat,
  gpuDoubleFloat,
  gpuPerturbation,
  cpu,
}

/// User-visible tier selected by the deep-zoom precision ladder.
enum PrecisionLadderTier {
  realtimeGpu,
  extendedGpu,
  precisionRefine,
}

/// Honesty marker for the selected precision path.
enum PrecisionLadderExactness {
  approximate,
  extendedGpuPreview,
  cpuPrecision,
}

/// Replayable precision-ladder decision for a module/zoom sample.
@immutable
class PrecisionLadderDecision {
  final String moduleId;
  final FractalDimension dimension;
  final double zoom;
  final PrecisionLadderRenderPath renderPath;
  final PrecisionLadderTier tier;
  final PrecisionLadderExactness exactness;

  /// True when the CPU threshold has been crossed but hysteresis has not yet
  /// committed the renderer to CPU.
  final bool cpuFallbackPending;

  const PrecisionLadderDecision({
    required this.moduleId,
    required this.dimension,
    required this.zoom,
    required this.renderPath,
    required this.tier,
    required this.exactness,
    this.cpuFallbackPending = false,
  });

  bool get usesCpuRenderer => renderPath == PrecisionLadderRenderPath.cpu;

  bool get usesDoubleFloatGpu =>
      renderPath == PrecisionLadderRenderPath.gpuDoubleFloat;

  bool get usesPerturbationGpu =>
      renderPath == PrecisionLadderRenderPath.gpuPerturbation;

  bool get usesExtendedGpu => usesDoubleFloatGpu || usesPerturbationGpu;

  bool get showPrecisionIndicator =>
      tier != PrecisionLadderTier.realtimeGpu || cpuFallbackPending;

  String get statusLabel {
    switch (tier) {
      case PrecisionLadderTier.realtimeGpu:
        return cpuFallbackPending ? 'Precision pending' : 'GPU';
      case PrecisionLadderTier.extendedGpu:
        return 'Deep GPU preview';
      case PrecisionLadderTier.precisionRefine:
        return 'CPU Precision';
    }
  }

  String get debugRendererLabel {
    switch (renderPath) {
      case PrecisionLadderRenderPath.gpuFloat:
        return 'GPU';
      case PrecisionLadderRenderPath.gpuDoubleFloat:
        return 'GPU-DF2';
      case PrecisionLadderRenderPath.gpuPerturbation:
        return 'GPU-PERTURB';
      case PrecisionLadderRenderPath.cpu:
        return 'CPU';
    }
  }
}

@immutable
class _PrecisionThresholds {
  final double cpuFallbackZoom;
  final double? doubleFloatLowerZoom;
  final double? doubleFloatUpperZoom;

  const _PrecisionThresholds({
    required this.cpuFallbackZoom,
    this.doubleFloatLowerZoom,
    this.doubleFloatUpperZoom,
  });

  bool shouldUseCpuFallback(double zoom) => zoom >= cpuFallbackZoom;

  bool shouldUseDoubleFloat(double zoom) {
    final lower = doubleFloatLowerZoom;
    final upper = doubleFloatUpperZoom;
    if (lower == null || upper == null) return false;
    return zoom >= lower && zoom < upper;
  }
}

class _PrecisionThresholdPolicy {
  static const int _gpuMaxIterations = 2000;
  static const int hysteresisFrames = 2;
  static const _mandelbrotDf2LowerThreshold = 5e6;

  static const _moduleThresholds = <String, _PrecisionThresholds>{
    'mandelbrot': _PrecisionThresholds(
      cpuFallbackZoom: _mandelbrotDf2UpperThreshold,
      doubleFloatLowerZoom: _mandelbrotDf2LowerThreshold,
      doubleFloatUpperZoom: _mandelbrotDf2UpperThreshold,
    ),
    'julia': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'celtic': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'buffalo': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'burning_ship': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'tricorn': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'multibrot3': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'multibrot4': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'multibrot5': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'phoenix': _PrecisionThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'weierstrass_p': _PrecisionThresholds(cpuFallbackZoom: 1e5),
  };

  static const _defaultThresholds = _PrecisionThresholds(
    cpuFallbackZoom: _defaultCpuFallbackThreshold,
  );

  const _PrecisionThresholdPolicy();

  _PrecisionThresholds thresholdsFor(String moduleId) =>
      _moduleThresholds[moduleId] ?? _defaultThresholds;

  bool shouldUseCpuFallback({
    required String moduleId,
    required double zoom,
  }) =>
      thresholdsFor(moduleId).shouldUseCpuFallback(zoom);

  bool shouldUseDoubleFloat({
    required String moduleId,
    required double zoom,
  }) =>
      thresholdsFor(moduleId).shouldUseDoubleFloat(zoom);

  double thresholdFor(String moduleId) =>
      thresholdsFor(moduleId).cpuFallbackZoom;

  int scaledGpuIterations({
    required int baseIterations,
    required double zoom,
  }) {
    final safeBase = baseIterations.clamp(4, _gpuMaxIterations);
    final depth = _zoomDepthLog10(zoom);
    if (depth == 0.0) return safeBase;

    final factor = 1.0 + 0.35 * depth;
    final scaled = (safeBase * factor).round();
    return scaled.clamp(4, _gpuMaxIterations);
  }
}

/// Pure precision-ladder decision Module.
///
/// This Module owns the current first-slice routing decision: standard GPU,
/// extended GPU (double-float or perturbation), or CPU precision. It does not
/// schedule two-phase refine work; callers can still use the decision to keep
/// preview/refine UI copy honest while that pipeline is deferred.
class PrecisionLadderPolicy {
  static const _thresholdPolicy = _PrecisionThresholdPolicy();

  const PrecisionLadderPolicy();

  PrecisionLadderDecision decide({
    required String moduleId,
    required FractalDimension dimension,
    required double zoom,
    bool cpuFallbackActive = true,
  }) {
    if (dimension != FractalDimension.twoD) {
      return PrecisionLadderDecision(
        moduleId: moduleId,
        dimension: dimension,
        zoom: zoom,
        renderPath: PrecisionLadderRenderPath.gpuFloat,
        tier: PrecisionLadderTier.realtimeGpu,
        exactness: PrecisionLadderExactness.approximate,
      );
    }

    if (_shouldUsePerturbationGpu(moduleId: moduleId, zoom: zoom)) {
      return PrecisionLadderDecision(
        moduleId: moduleId,
        dimension: dimension,
        zoom: zoom,
        renderPath: PrecisionLadderRenderPath.gpuPerturbation,
        tier: PrecisionLadderTier.extendedGpu,
        exactness: PrecisionLadderExactness.extendedGpuPreview,
      );
    }

    if (_thresholdPolicy.shouldUseDoubleFloat(
      moduleId: moduleId,
      zoom: zoom,
    )) {
      return PrecisionLadderDecision(
        moduleId: moduleId,
        dimension: dimension,
        zoom: zoom,
        renderPath: PrecisionLadderRenderPath.gpuDoubleFloat,
        tier: PrecisionLadderTier.extendedGpu,
        exactness: PrecisionLadderExactness.extendedGpuPreview,
      );
    }

    final needsCpu = _thresholdPolicy.shouldUseCpuFallback(
      moduleId: moduleId,
      zoom: zoom,
    );
    if (needsCpu && cpuFallbackActive) {
      return PrecisionLadderDecision(
        moduleId: moduleId,
        dimension: dimension,
        zoom: zoom,
        renderPath: PrecisionLadderRenderPath.cpu,
        tier: PrecisionLadderTier.precisionRefine,
        exactness: PrecisionLadderExactness.cpuPrecision,
      );
    }

    return PrecisionLadderDecision(
      moduleId: moduleId,
      dimension: dimension,
      zoom: zoom,
      renderPath: PrecisionLadderRenderPath.gpuFloat,
      tier: PrecisionLadderTier.realtimeGpu,
      exactness: PrecisionLadderExactness.approximate,
      cpuFallbackPending: needsCpu,
    );
  }

  bool _shouldUsePerturbationGpu({
    required String moduleId,
    required double zoom,
  }) {
    if (!_supportsPerturbationGpu(moduleId)) return false;
    return zoom >= _extendedGpuLowerZoom && zoom < _perturbationUpperZoom;
  }

  bool _supportsPerturbationGpu(String moduleId) =>
      moduleId == 'julia' || kPerturbableEscapeTimeIds.contains(moduleId);

  /// Deepest zoom [moduleId] can still render on the GPU — via float32, the
  /// double-float shader, or perturbation — before CPU fallback is required.
  ///
  /// This is the GPU ceiling, not the float32 CPU-fallback threshold: for a
  /// perturbation-capable module that threshold is stale (perturbation extends
  /// the GPU range to [_perturbationUpperZoom]). Auto-explore uses this so it
  /// does not cap perturbable fractals far shallower than the renderer can go.
  double gpuRenderableCeilingZoom(String moduleId) {
    if (_supportsPerturbationGpu(moduleId)) return _perturbationUpperZoom;
    // mandelbrot's df2 shader already raises its CPU-fallback threshold; other
    // float32-only modules keep theirs.
    return _thresholdPolicy.thresholdFor(moduleId);
  }

  /// Scales realtime GPU iteration count for the active zoom depth.
  ///
  /// Renderer callers use this seam instead of reaching into deep-zoom
  /// thresholds directly; threshold policy stays an implementation detail of
  /// the Precision Ladder module.
  int scaledGpuIterations({
    required int baseIterations,
    required double zoom,
  }) {
    return _thresholdPolicy.scaledGpuIterations(
      baseIterations: baseIterations,
      zoom: zoom,
    );
  }
}

/// Replayable state for one Precision Ladder CPU activation streak.
///
/// Keeping the transition pure makes the hidden state/order dependence visible:
/// streaks are scoped to one module, below-threshold samples reset immediately,
/// and CPU Precision activates only after enough consecutive CPU candidates for
/// the same module.
@immutable
class PrecisionLadderHysteresisState {
  final String? moduleId;
  final int aboveThresholdCount;
  final bool cpuActive;

  const PrecisionLadderHysteresisState({
    required this.moduleId,
    required this.aboveThresholdCount,
    required this.cpuActive,
  });

  const PrecisionLadderHysteresisState.initial()
      : moduleId = null,
        aboveThresholdCount = 0,
        cpuActive = false;

  PrecisionLadderHysteresisState next({
    required String nextModuleId,
    required bool overThreshold,
    required int activationFrames,
  }) {
    assert(activationFrames > 0, 'activationFrames must be positive');
    final sameModule = moduleId == nextModuleId;
    final currentCount = sameModule ? aboveThresholdCount : 0;

    if (!overThreshold) {
      return PrecisionLadderHysteresisState(
        moduleId: nextModuleId,
        aboveThresholdCount: 0,
        cpuActive: false,
      );
    }

    final nextCount = currentCount + 1;
    return PrecisionLadderHysteresisState(
      moduleId: nextModuleId,
      aboveThresholdCount: nextCount,
      cpuActive: nextCount >= activationFrames,
    );
  }
}

/// Stateful hysteresis wrapper for CPU precision-refine activation.
///
/// The wrapped [PrecisionLadderPolicy] still owns the pure path decision; this
/// class only delays committing to the CPU path for consecutive CPU candidates.
class PrecisionLadderHysteresis {
  final PrecisionLadderPolicy policy;
  PrecisionLadderHysteresisState _state =
      const PrecisionLadderHysteresisState.initial();

  PrecisionLadderHysteresis({
    this.policy = const PrecisionLadderPolicy(),
  });

  PrecisionLadderHysteresisState get state => _state;

  PrecisionLadderDecision update({
    required String moduleId,
    required FractalDimension dimension,
    required double zoom,
  }) {
    final candidate = policy.decide(
      moduleId: moduleId,
      dimension: dimension,
      zoom: zoom,
    );

    _state = _state.next(
      nextModuleId: moduleId,
      overThreshold: candidate.usesCpuRenderer,
      activationFrames: _PrecisionThresholdPolicy.hysteresisFrames,
    );

    return policy.decide(
      moduleId: moduleId,
      dimension: dimension,
      zoom: zoom,
      cpuFallbackActive: _state.cpuActive,
    );
  }

  void reset() {
    _state = const PrecisionLadderHysteresisState.initial();
  }
}

double _zoomDepthLog10(double zoom) {
  if (zoom.isNaN || zoom <= 1.0) return 0.0;
  if (zoom.isInfinite) return 30.0;
  return (math.log(zoom) / math.ln10).clamp(0.0, 30.0);
}
