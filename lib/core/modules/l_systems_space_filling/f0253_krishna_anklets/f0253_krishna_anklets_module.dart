// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0253_krishna_anklets_presets.dart';
import 'f0253_krishna_anklets_variants.dart';
import 'f0253_krishna_anklets_metadata.dart';

/// Krishna Anklets — L-Systems & Space-Filling.
class F0253KrishnaAnklets extends LSystemModule {
  F0253KrishnaAnklets()
      : super(
          id: 'f0253_krishna_anklets',
          shader: 'shaders/f0253_krishna_anklets_gpu.frag',
        );

  @override
  F0253KrishnaAnkletsMetadata get metadata => F0253KrishnaAnkletsMetadata.instance;

  @override
  List<F0253KrishnaAnkletsPreset> get presets => F0253KrishnaAnkletsPresets.all;

  @override
  List<F0253KrishnaAnkletsVariant> get variants => F0253KrishnaAnkletsVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
