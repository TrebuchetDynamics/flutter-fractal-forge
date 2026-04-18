// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1068_tyler_web_presets.dart';
import 'f1068_tyler_web_variants.dart';
import 'f1068_tyler_web_metadata.dart';

/// Tyler Web — Strange Attractors.
class F1068TylerWeb extends AttractorModule {
  F1068TylerWeb()
      : super(
          id: 'f1068_tyler_web',
          shader: 'shaders/f1068_tyler_web_gpu.frag',
        );

  @override
  F1068TylerWebMetadata get metadata => F1068TylerWebMetadata.instance;

  @override
  List<F1068TylerWebPreset> get presets => F1068TylerWebPresets.all;

  @override
  List<F1068TylerWebVariant> get variants => F1068TylerWebVariants.all;

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
