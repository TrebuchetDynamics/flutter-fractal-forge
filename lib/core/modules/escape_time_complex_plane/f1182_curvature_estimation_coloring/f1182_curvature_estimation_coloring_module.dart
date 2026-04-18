// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1182_curvature_estimation_coloring_presets.dart';
import 'f1182_curvature_estimation_coloring_variants.dart';
import 'f1182_curvature_estimation_coloring_metadata.dart';

/// Curvature Estimation Coloring — Escape-Time (Complex Plane).
class F1182CurvatureEstimationColoring extends EscapeTimeModule {
  F1182CurvatureEstimationColoring()
      : super(
          id: 'f1182_curvature_estimation_coloring',
          shader: 'shaders/f1182_curvature_estimation_coloring_gpu.frag',
        );

  @override
  F1182CurvatureEstimationColoringMetadata get metadata => F1182CurvatureEstimationColoringMetadata.instance;

  @override
  List<F1182CurvatureEstimationColoringPreset> get presets => F1182CurvatureEstimationColoringPresets.all;

  @override
  List<F1182CurvatureEstimationColoringVariant> get variants => F1182CurvatureEstimationColoringVariants.all;

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
