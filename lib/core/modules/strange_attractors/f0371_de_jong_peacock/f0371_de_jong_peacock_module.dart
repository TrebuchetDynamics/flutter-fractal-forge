// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0371_de_jong_peacock_presets.dart';
import 'f0371_de_jong_peacock_variants.dart';
import 'f0371_de_jong_peacock_metadata.dart';

/// de Jong Peacock — Strange Attractors.
class F0371DeJongPeacock extends AttractorModule {
  F0371DeJongPeacock()
      : super(
          id: 'f0371_de_jong_peacock',
          shader: 'shaders/f0371_de_jong_peacock_gpu.frag',
        );

  @override
  F0371DeJongPeacockMetadata get metadata => F0371DeJongPeacockMetadata.instance;

  @override
  List<F0371DeJongPeacockPreset> get presets => F0371DeJongPeacockPresets.all;

  @override
  List<F0371DeJongPeacockVariant> get variants => F0371DeJongPeacockVariants.all;

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
