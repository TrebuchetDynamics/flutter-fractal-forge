// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0248_weed_presets.dart';
import 'f0248_weed_variants.dart';
import 'f0248_weed_metadata.dart';

/// Weed — L-Systems & Space-Filling.
class F0248Weed extends LSystemModule {
  F0248Weed()
      : super(
          id: 'f0248_weed',
          shader: 'shaders/f0248_weed_gpu.frag',
        );

  @override
  F0248WeedMetadata get metadata => F0248WeedMetadata.instance;

  @override
  List<F0248WeedPreset> get presets => F0248WeedPresets.all;

  @override
  List<F0248WeedVariant> get variants => F0248WeedVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
