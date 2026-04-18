// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1035_martin_hopalong_spider_presets.dart';
import 'f1035_martin_hopalong_spider_variants.dart';
import 'f1035_martin_hopalong_spider_metadata.dart';

/// Martin Hopalong Spider — Strange Attractors.
class F1035MartinHopalongSpider extends AttractorModule {
  F1035MartinHopalongSpider()
      : super(
          id: 'f1035_martin_hopalong_spider',
          shader: 'shaders/f1035_martin_hopalong_spider_gpu.frag',
        );

  @override
  F1035MartinHopalongSpiderMetadata get metadata => F1035MartinHopalongSpiderMetadata.instance;

  @override
  List<F1035MartinHopalongSpiderPreset> get presets => F1035MartinHopalongSpiderPresets.all;

  @override
  List<F1035MartinHopalongSpiderVariant> get variants => F1035MartinHopalongSpiderVariants.all;

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
