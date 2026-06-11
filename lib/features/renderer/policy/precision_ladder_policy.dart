import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

import 'deep_zoom_precision_policy.dart';

const double _extendedGpuLowerZoom = 5e6;
const double _perturbationUpperZoom = 1e30;

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

/// Pure precision-ladder decision Module.
///
/// This Module owns the current first-slice routing decision: standard GPU,
/// extended GPU (double-float or perturbation), or CPU precision. It does not
/// schedule two-phase refine work; callers can still use the decision to keep
/// preview/refine UI copy honest while that pipeline is deferred.
class PrecisionLadderPolicy {
  final DeepZoomPrecisionPolicy deepZoomPolicy;

  const PrecisionLadderPolicy({
    this.deepZoomPolicy = const DeepZoomPrecisionPolicy(),
  });

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

    if (deepZoomPolicy.shouldUseDoubleFloat(
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

    final needsCpu = deepZoomPolicy.shouldUseCpuFallback(
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
}

/// Stateful hysteresis wrapper for CPU precision-refine activation.
///
/// The wrapped [PrecisionLadderPolicy] still owns the pure path decision; this
/// class only delays committing to the CPU path for consecutive CPU candidates.
class PrecisionLadderHysteresis {
  final PrecisionLadderPolicy policy;
  DeepZoomHysteresisState _state = const DeepZoomHysteresisState.initial();

  PrecisionLadderHysteresis({
    this.policy = const PrecisionLadderPolicy(),
  });

  DeepZoomHysteresisState get state => _state;

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
      activationFrames: policy.deepZoomPolicy.hysteresisFrames,
    );

    return policy.decide(
      moduleId: moduleId,
      dimension: dimension,
      zoom: zoom,
      cpuFallbackActive: _state.cpuActive,
    );
  }

  void reset() {
    _state = const DeepZoomHysteresisState.initial();
  }
}
