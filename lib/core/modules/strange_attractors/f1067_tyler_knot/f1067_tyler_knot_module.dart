// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1067_tyler_knot_presets.dart';
import 'f1067_tyler_knot_variants.dart';
import 'f1067_tyler_knot_metadata.dart';

/// Tyler Knot — Strange Attractors.
class F1067TylerKnot extends AttractorModule {
  F1067TylerKnot()
      : super(
          id: 'f1067_tyler_knot',
          shader: 'shaders/f1067_tyler_knot_gpu.frag',
        );

  @override
  F1067TylerKnotMetadata get metadata => F1067TylerKnotMetadata.instance;

  @override
  List<F1067TylerKnotPreset> get presets => F1067TylerKnotPresets.all;

  @override
  List<F1067TylerKnotVariant> get variants => F1067TylerKnotVariants.all;

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
