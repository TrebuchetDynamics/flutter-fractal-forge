// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0380_de_jong_leaf_presets.dart';
import 'f0380_de_jong_leaf_variants.dart';
import 'f0380_de_jong_leaf_metadata.dart';

/// de Jong Leaf — Strange Attractors.
class F0380DeJongLeaf extends AttractorModule {
  F0380DeJongLeaf()
      : super(
          id: 'f0380_de_jong_leaf',
          shader: 'shaders/f0380_de_jong_leaf_gpu.frag',
        );

  @override
  F0380DeJongLeafMetadata get metadata => F0380DeJongLeafMetadata.instance;

  @override
  List<F0380DeJongLeafPreset> get presets => F0380DeJongLeafPresets.all;

  @override
  List<F0380DeJongLeafVariant> get variants => F0380DeJongLeafVariants.all;

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
