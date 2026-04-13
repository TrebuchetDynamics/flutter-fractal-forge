// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0377_de_jong_filigree_presets.dart';
import 'f0377_de_jong_filigree_variants.dart';
import 'f0377_de_jong_filigree_metadata.dart';

/// de Jong Filigree — Strange Attractors.
class F0377DeJongFiligree extends AttractorModule {
  F0377DeJongFiligree()
      : super(
          id: 'f0377_de_jong_filigree',
          shader: 'shaders/f0377_de_jong_filigree_gpu.frag',
        );

  @override
  F0377DeJongFiligreeMetadata get metadata => F0377DeJongFiligreeMetadata.instance;

  @override
  List<F0377DeJongFiligreePreset> get presets => F0377DeJongFiligreePresets.all;

  @override
  List<F0377DeJongFiligreeVariant> get variants => F0377DeJongFiligreeVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
