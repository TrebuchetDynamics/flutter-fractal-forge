// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1037_martin_hopalong_mosaic_presets.dart';
import 'f1037_martin_hopalong_mosaic_variants.dart';
import 'f1037_martin_hopalong_mosaic_metadata.dart';

/// Martin Hopalong Mosaic — Strange Attractors.
class F1037MartinHopalongMosaic extends AttractorModule {
  F1037MartinHopalongMosaic()
      : super(
          id: 'f1037_martin_hopalong_mosaic',
          shader: 'shaders/f1037_martin_hopalong_mosaic_gpu.frag',
        );

  @override
  F1037MartinHopalongMosaicMetadata get metadata => F1037MartinHopalongMosaicMetadata.instance;

  @override
  List<F1037MartinHopalongMosaicPreset> get presets => F1037MartinHopalongMosaicPresets.all;

  @override
  List<F1037MartinHopalongMosaicVariant> get variants => F1037MartinHopalongMosaicVariants.all;

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
