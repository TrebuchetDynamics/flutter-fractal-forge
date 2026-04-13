// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0378_de_jong_cloud_presets.dart';
import 'f0378_de_jong_cloud_variants.dart';
import 'f0378_de_jong_cloud_metadata.dart';

/// de Jong Cloud — Strange Attractors.
class F0378DeJongCloud extends AttractorModule {
  F0378DeJongCloud()
      : super(
          id: 'f0378_de_jong_cloud',
          shader: 'shaders/f0378_de_jong_cloud_gpu.frag',
        );

  @override
  F0378DeJongCloudMetadata get metadata => F0378DeJongCloudMetadata.instance;

  @override
  List<F0378DeJongCloudPreset> get presets => F0378DeJongCloudPresets.all;

  @override
  List<F0378DeJongCloudVariant> get variants => F0378DeJongCloudVariants.all;

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
