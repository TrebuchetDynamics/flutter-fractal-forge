// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0013_polynomiography_basic_family_iteration_presets.dart';
import 'f0013_polynomiography_basic_family_iteration_variants.dart';
import 'f0013_polynomiography_basic_family_iteration_metadata.dart';

/// Polynomiography (Basic Family Iteration) — Newton / Root-Finding.
class F0013PolynomiographyBasicFamilyIteration extends EscapeTimeModule {
  F0013PolynomiographyBasicFamilyIteration()
      : super(
          id: 'f0013_polynomiography_basic_family_iteration',
          shader: 'shaders/f0013_polynomiography_basic_family_iteration_gpu.frag',
        );

  @override
  F0013PolynomiographyBasicFamilyIterationMetadata get metadata => F0013PolynomiographyBasicFamilyIterationMetadata.instance;

  @override
  List<F0013PolynomiographyBasicFamilyIterationPreset> get presets => F0013PolynomiographyBasicFamilyIterationPresets.all;

  @override
  List<F0013PolynomiographyBasicFamilyIterationVariant> get variants => F0013PolynomiographyBasicFamilyIterationVariants.all;

  @override
  double get defaultPower => 3.0;

  @override
  double get defaultBailout => 0.001;

  @override
  int get defaultIterations => 64;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
