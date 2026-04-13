// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0261_lute_of_pythagoras_presets.dart';
import 'f0261_lute_of_pythagoras_variants.dart';
import 'f0261_lute_of_pythagoras_metadata.dart';

/// Lute of Pythagoras — L-Systems & Space-Filling.
class F0261LuteOfPythagoras extends LSystemModule {
  F0261LuteOfPythagoras()
      : super(
          id: 'f0261_lute_of_pythagoras',
          shader: 'shaders/f0261_lute_of_pythagoras_gpu.frag',
        );

  @override
  F0261LuteOfPythagorasMetadata get metadata => F0261LuteOfPythagorasMetadata.instance;

  @override
  List<F0261LuteOfPythagorasPreset> get presets => F0261LuteOfPythagorasPresets.all;

  @override
  List<F0261LuteOfPythagorasVariant> get variants => F0261LuteOfPythagorasVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
