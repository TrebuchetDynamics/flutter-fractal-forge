// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1085_bogdanov_spiral_presets.dart';
import 'f1085_bogdanov_spiral_variants.dart';
import 'f1085_bogdanov_spiral_metadata.dart';

/// Bogdanov Spiral — Strange Attractors.
class F1085BogdanovSpiral extends AttractorModule {
  F1085BogdanovSpiral()
      : super(
          id: 'f1085_bogdanov_spiral',
          shader: 'shaders/f1085_bogdanov_spiral_gpu.frag',
        );

  @override
  F1085BogdanovSpiralMetadata get metadata => F1085BogdanovSpiralMetadata.instance;

  @override
  List<F1085BogdanovSpiralPreset> get presets => F1085BogdanovSpiralPresets.all;

  @override
  List<F1085BogdanovSpiralVariant> get variants => F1085BogdanovSpiralVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
