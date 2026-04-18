// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0839_hex_gosper_presets.dart';
import 'f0839_hex_gosper_variants.dart';
import 'f0839_hex_gosper_metadata.dart';

/// Hex-Gosper — L-Systems & Space-Filling.
class F0839HexGosper extends LSystemModule {
  F0839HexGosper()
      : super(
          id: 'f0839_hex_gosper',
          shader: 'shaders/f0839_hex_gosper_gpu.frag',
        );

  @override
  F0839HexGosperMetadata get metadata => F0839HexGosperMetadata.instance;

  @override
  List<F0839HexGosperPreset> get presets => F0839HexGosperPresets.all;

  @override
  List<F0839HexGosperVariant> get variants => F0839HexGosperVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
