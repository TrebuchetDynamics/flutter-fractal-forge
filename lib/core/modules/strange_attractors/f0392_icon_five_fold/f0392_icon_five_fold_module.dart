// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0392_icon_five_fold_presets.dart';
import 'f0392_icon_five_fold_variants.dart';
import 'f0392_icon_five_fold_metadata.dart';

/// Icon — Five-Fold — Strange Attractors.
class F0392IconFiveFold extends AttractorModule {
  F0392IconFiveFold()
      : super(
          id: 'f0392_icon_five_fold',
          shader: 'shaders/f0392_icon_five_fold_gpu.frag',
        );

  @override
  F0392IconFiveFoldMetadata get metadata => F0392IconFiveFoldMetadata.instance;

  @override
  List<F0392IconFiveFoldPreset> get presets => F0392IconFiveFoldPresets.all;

  @override
  List<F0392IconFiveFoldVariant> get variants => F0392IconFiveFoldVariants.all;

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
