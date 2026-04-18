// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1181_triangle_inequality_average_presets.dart';
import 'f1181_triangle_inequality_average_variants.dart';
import 'f1181_triangle_inequality_average_metadata.dart';

/// Triangle Inequality Average — Escape-Time (Complex Plane).
class F1181TriangleInequalityAverage extends EscapeTimeModule {
  F1181TriangleInequalityAverage()
      : super(
          id: 'f1181_triangle_inequality_average',
          shader: 'shaders/f1181_triangle_inequality_average_gpu.frag',
        );

  @override
  F1181TriangleInequalityAverageMetadata get metadata => F1181TriangleInequalityAverageMetadata.instance;

  @override
  List<F1181TriangleInequalityAveragePreset> get presets => F1181TriangleInequalityAveragePresets.all;

  @override
  List<F1181TriangleInequalityAverageVariant> get variants => F1181TriangleInequalityAverageVariants.all;

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
