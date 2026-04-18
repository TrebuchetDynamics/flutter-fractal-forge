// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0761_devil_s_staircase_cantor_function_presets.dart';
import 'f0761_devil_s_staircase_cantor_function_variants.dart';
import 'f0761_devil_s_staircase_cantor_function_metadata.dart';

/// Devil's Staircase (Cantor Function) — Number-Theory Fractals.
class F0761DevilSStaircaseCantorFunction extends CellularModule {
  F0761DevilSStaircaseCantorFunction()
      : super(
          id: 'f0761_devil_s_staircase_cantor_function',
          shader: 'shaders/f0761_devil_s_staircase_cantor_function_gpu.frag',
        );

  @override
  F0761DevilSStaircaseCantorFunctionMetadata get metadata => F0761DevilSStaircaseCantorFunctionMetadata.instance;

  @override
  List<F0761DevilSStaircaseCantorFunctionPreset> get presets => F0761DevilSStaircaseCantorFunctionPresets.all;

  @override
  List<F0761DevilSStaircaseCantorFunctionVariant> get variants => F0761DevilSStaircaseCantorFunctionVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
