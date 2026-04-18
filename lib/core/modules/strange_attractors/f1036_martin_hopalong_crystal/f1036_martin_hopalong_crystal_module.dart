// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1036_martin_hopalong_crystal_presets.dart';
import 'f1036_martin_hopalong_crystal_variants.dart';
import 'f1036_martin_hopalong_crystal_metadata.dart';

/// Martin Hopalong Crystal — Strange Attractors.
class F1036MartinHopalongCrystal extends AttractorModule {
  F1036MartinHopalongCrystal()
      : super(
          id: 'f1036_martin_hopalong_crystal',
          shader: 'shaders/f1036_martin_hopalong_crystal_gpu.frag',
        );

  @override
  F1036MartinHopalongCrystalMetadata get metadata => F1036MartinHopalongCrystalMetadata.instance;

  @override
  List<F1036MartinHopalongCrystalPreset> get presets => F1036MartinHopalongCrystalPresets.all;

  @override
  List<F1036MartinHopalongCrystalVariant> get variants => F1036MartinHopalongCrystalVariants.all;

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
