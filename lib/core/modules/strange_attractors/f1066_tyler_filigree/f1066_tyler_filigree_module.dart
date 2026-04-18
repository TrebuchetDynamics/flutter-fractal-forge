// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1066_tyler_filigree_presets.dart';
import 'f1066_tyler_filigree_variants.dart';
import 'f1066_tyler_filigree_metadata.dart';

/// Tyler Filigree — Strange Attractors.
class F1066TylerFiligree extends AttractorModule {
  F1066TylerFiligree()
      : super(
          id: 'f1066_tyler_filigree',
          shader: 'shaders/f1066_tyler_filigree_gpu.frag',
        );

  @override
  F1066TylerFiligreeMetadata get metadata => F1066TylerFiligreeMetadata.instance;

  @override
  List<F1066TylerFiligreePreset> get presets => F1066TylerFiligreePresets.all;

  @override
  List<F1066TylerFiligreeVariant> get variants => F1066TylerFiligreeVariants.all;

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
