// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0760_minkowski_question_mark_function_presets.dart';
import 'f0760_minkowski_question_mark_function_variants.dart';
import 'f0760_minkowski_question_mark_function_metadata.dart';

/// Minkowski Question Mark Function — Number-Theory Fractals.
class F0760MinkowskiQuestionMarkFunction extends CellularModule {
  F0760MinkowskiQuestionMarkFunction()
      : super(
          id: 'f0760_minkowski_question_mark_function',
          shader: 'shaders/f0760_minkowski_question_mark_function_gpu.frag',
        );

  @override
  F0760MinkowskiQuestionMarkFunctionMetadata get metadata => F0760MinkowskiQuestionMarkFunctionMetadata.instance;

  @override
  List<F0760MinkowskiQuestionMarkFunctionPreset> get presets => F0760MinkowskiQuestionMarkFunctionPresets.all;

  @override
  List<F0760MinkowskiQuestionMarkFunctionVariant> get variants => F0760MinkowskiQuestionMarkFunctionVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
