// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0430_quad_spiral_presets.dart';
import 'f0430_quad_spiral_variants.dart';
import 'f0430_quad_spiral_metadata.dart';

/// Quad Spiral — Escape-Time (Complex Plane).
class F0430QuadSpiral extends EscapeTimeModule {
  F0430QuadSpiral()
      : super(
          id: 'f0430_quad_spiral',
          shader: 'shaders/f0430_quad_spiral_gpu.frag',
        );

  @override
  F0430QuadSpiralMetadata get metadata => F0430QuadSpiralMetadata.instance;

  @override
  List<F0430QuadSpiralPreset> get presets => F0430QuadSpiralPresets.all;

  @override
  List<F0430QuadSpiralVariant> get variants => F0430QuadSpiralVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
