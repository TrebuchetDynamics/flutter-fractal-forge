// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1040_martin_hopalong_rosette_presets.dart';
import 'f1040_martin_hopalong_rosette_variants.dart';
import 'f1040_martin_hopalong_rosette_metadata.dart';

/// Martin Hopalong Rosette — Strange Attractors.
class F1040MartinHopalongRosette extends AttractorModule {
  F1040MartinHopalongRosette()
      : super(
          id: 'f1040_martin_hopalong_rosette',
          shader: 'shaders/f1040_martin_hopalong_rosette_gpu.frag',
        );

  @override
  F1040MartinHopalongRosetteMetadata get metadata => F1040MartinHopalongRosetteMetadata.instance;

  @override
  List<F1040MartinHopalongRosettePreset> get presets => F1040MartinHopalongRosettePresets.all;

  @override
  List<F1040MartinHopalongRosetteVariant> get variants => F1040MartinHopalongRosetteVariants.all;

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
