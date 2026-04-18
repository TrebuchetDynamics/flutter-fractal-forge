// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1062_tyler_flower_presets.dart';
import 'f1062_tyler_flower_variants.dart';
import 'f1062_tyler_flower_metadata.dart';

/// Tyler Flower — Strange Attractors.
class F1062TylerFlower extends AttractorModule {
  F1062TylerFlower()
      : super(
          id: 'f1062_tyler_flower',
          shader: 'shaders/f1062_tyler_flower_gpu.frag',
        );

  @override
  F1062TylerFlowerMetadata get metadata => F1062TylerFlowerMetadata.instance;

  @override
  List<F1062TylerFlowerPreset> get presets => F1062TylerFlowerPresets.all;

  @override
  List<F1062TylerFlowerVariant> get variants => F1062TylerFlowerVariants.all;

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
