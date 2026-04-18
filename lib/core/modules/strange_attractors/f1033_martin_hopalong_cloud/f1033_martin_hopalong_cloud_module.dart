// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1033_martin_hopalong_cloud_presets.dart';
import 'f1033_martin_hopalong_cloud_variants.dart';
import 'f1033_martin_hopalong_cloud_metadata.dart';

/// Martin Hopalong Cloud — Strange Attractors.
class F1033MartinHopalongCloud extends AttractorModule {
  F1033MartinHopalongCloud()
      : super(
          id: 'f1033_martin_hopalong_cloud',
          shader: 'shaders/f1033_martin_hopalong_cloud_gpu.frag',
        );

  @override
  F1033MartinHopalongCloudMetadata get metadata => F1033MartinHopalongCloudMetadata.instance;

  @override
  List<F1033MartinHopalongCloudPreset> get presets => F1033MartinHopalongCloudPresets.all;

  @override
  List<F1033MartinHopalongCloudVariant> get variants => F1033MartinHopalongCloudVariants.all;

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
