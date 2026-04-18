// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1061_tyler_spiral_presets.dart';
import 'f1061_tyler_spiral_variants.dart';
import 'f1061_tyler_spiral_metadata.dart';

/// Tyler Spiral — Strange Attractors.
class F1061TylerSpiral extends AttractorModule {
  F1061TylerSpiral()
      : super(
          id: 'f1061_tyler_spiral',
          shader: 'shaders/f1061_tyler_spiral_gpu.frag',
        );

  @override
  F1061TylerSpiralMetadata get metadata => F1061TylerSpiralMetadata.instance;

  @override
  List<F1061TylerSpiralPreset> get presets => F1061TylerSpiralPresets.all;

  @override
  List<F1061TylerSpiralVariant> get variants => F1061TylerSpiralVariants.all;

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
