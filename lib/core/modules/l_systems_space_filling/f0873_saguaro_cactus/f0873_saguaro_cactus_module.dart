// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0873_saguaro_cactus_presets.dart';
import 'f0873_saguaro_cactus_variants.dart';
import 'f0873_saguaro_cactus_metadata.dart';

/// Saguaro Cactus — L-Systems & Space-Filling.
class F0873SaguaroCactus extends LSystemModule {
  F0873SaguaroCactus()
      : super(
          id: 'f0873_saguaro_cactus',
          shader: 'shaders/f0873_saguaro_cactus_gpu.frag',
        );

  @override
  F0873SaguaroCactusMetadata get metadata => F0873SaguaroCactusMetadata.instance;

  @override
  List<F0873SaguaroCactusPreset> get presets => F0873SaguaroCactusPresets.all;

  @override
  List<F0873SaguaroCactusVariant> get variants => F0873SaguaroCactusVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
