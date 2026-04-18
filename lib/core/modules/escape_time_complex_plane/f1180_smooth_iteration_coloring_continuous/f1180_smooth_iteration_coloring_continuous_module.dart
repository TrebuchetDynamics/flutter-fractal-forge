// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1180_smooth_iteration_coloring_continuous_presets.dart';
import 'f1180_smooth_iteration_coloring_continuous_variants.dart';
import 'f1180_smooth_iteration_coloring_continuous_metadata.dart';

/// Smooth Iteration Coloring (Continuous) — Escape-Time (Complex Plane).
class F1180SmoothIterationColoringContinuous extends EscapeTimeModule {
  F1180SmoothIterationColoringContinuous()
      : super(
          id: 'f1180_smooth_iteration_coloring_continuous',
          shader: 'shaders/f1180_smooth_iteration_coloring_continuous_gpu.frag',
        );

  @override
  F1180SmoothIterationColoringContinuousMetadata get metadata => F1180SmoothIterationColoringContinuousMetadata.instance;

  @override
  List<F1180SmoothIterationColoringContinuousPreset> get presets => F1180SmoothIterationColoringContinuousPresets.all;

  @override
  List<F1180SmoothIterationColoringContinuousVariant> get variants => F1180SmoothIterationColoringContinuousVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1024;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
