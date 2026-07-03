import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/mandelbrot_df2_module.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/policy/backend_policy.dart';
import 'package:flutter_fractals/features/renderer/policy/precision_ladder_policy.dart';

/// Single render-path plan consumed by viewer chrome and renderer routing.
@immutable
class RendererPlan {
  final PrecisionLadderDecision precision;
  final BackendDecision backend;

  const RendererPlan({
    required this.precision,
    required this.backend,
  });

  const RendererPlan.gpu(this.precision)
      : backend = const BackendDecision(
          backend: RendererBackend.gpu,
          reasonCode: FallbackReasonCode.none,
          detail: 'renderer_default',
        );

  bool get usesCpuRenderer => backend.backend == RendererBackend.cpu;
  bool get usesGpuRenderer => backend.backend == RendererBackend.gpu;
}

class RendererPlanModuleResolver {
  FractalModule? _df2Module;
  FractalModule? _escapeTimePerturbModule;
  String _escapeTimePerturbModuleId = '';

  FractalModule resolve({
    required RendererPlan plan,
    required FractalModule module,
  }) {
    final precision = plan.precision;
    if (precision.usesDoubleFloatGpu && module.id == 'mandelbrot') {
      return _df2Module ??= buildMandelbrotDf2Module(module);
    }
    if (!precision.usesPerturbationGpu) return module;
    if (_escapeTimePerturbModuleId != module.id) {
      _escapeTimePerturbModule = buildEscapeTimePerturbModule(module);
      _escapeTimePerturbModuleId = module.id;
    }
    return _escapeTimePerturbModule!;
  }
}

class RendererPlanPolicy {
  final RendererBackendPolicy backendPolicy;

  const RendererPlanPolicy({
    this.backendPolicy = const RendererBackendPolicy(),
  });

  RendererPlan decide({
    required PrecisionLadderDecision precision,
    required RendererBackendMode userMode,
    required bool gpuHealthFailed,
    required bool isAndroid,
    required bool isWeb,
    required bool isEmulator,
  }) {
    final backend = backendPolicy.decide(
      BackendPolicyInput(
        isAndroid: isAndroid,
        isWeb: isWeb,
        isEmulator: isEmulator,
        userMode: userMode,
        gpuHealthFailed: gpuHealthFailed,
        deepZoomNeedsCpu: precision.usesCpuRenderer,
        dimension: precision.dimension,
      ),
    );
    return RendererPlan(precision: precision, backend: backend);
  }
}
