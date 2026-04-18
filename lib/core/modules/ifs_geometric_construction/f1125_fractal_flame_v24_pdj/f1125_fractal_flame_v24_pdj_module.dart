// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1125_fractal_flame_v24_pdj_presets.dart';
import 'f1125_fractal_flame_v24_pdj_variants.dart';
import 'f1125_fractal_flame_v24_pdj_metadata.dart';

/// Fractal Flame V24 PDJ — IFS & Geometric Construction.
class F1125FractalFlameV24Pdj extends IFSModule {
  F1125FractalFlameV24Pdj()
      : super(
          id: 'f1125_fractal_flame_v24_pdj',
          shader: 'shaders/f1125_fractal_flame_v24_pdj_gpu.frag',
        );

  @override
  F1125FractalFlameV24PdjMetadata get metadata => F1125FractalFlameV24PdjMetadata.instance;

  @override
  List<F1125FractalFlameV24PdjPreset> get presets => F1125FractalFlameV24PdjPresets.all;

  @override
  List<F1125FractalFlameV24PdjVariant> get variants => F1125FractalFlameV24PdjVariants.all;

  @override
  int get defaultIterations => 250000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
