// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0197_near_boundary_julia_presets.dart';
import 'f0197_near_boundary_julia_variants.dart';
import 'f0197_near_boundary_julia_metadata.dart';

/// Near-Boundary Julia — Escape-Time (Complex Plane).
class F0197NearBoundaryJulia extends EscapeTimeModule {
  F0197NearBoundaryJulia()
      : super(
          id: 'f0197_near_boundary_julia',
          shader: 'shaders/f0197_near_boundary_julia_gpu.frag',
        );

  @override
  F0197NearBoundaryJuliaMetadata get metadata => F0197NearBoundaryJuliaMetadata.instance;

  @override
  List<F0197NearBoundaryJuliaPreset> get presets => F0197NearBoundaryJuliaPresets.all;

  @override
  List<F0197NearBoundaryJuliaVariant> get variants => F0197NearBoundaryJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
