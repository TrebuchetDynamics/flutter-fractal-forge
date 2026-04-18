// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0853_christmas_tree_snowy_presets.dart';
import 'f0853_christmas_tree_snowy_variants.dart';
import 'f0853_christmas_tree_snowy_metadata.dart';

/// Christmas Tree Snowy — L-Systems & Space-Filling.
class F0853ChristmasTreeSnowy extends LSystemModule {
  F0853ChristmasTreeSnowy()
      : super(
          id: 'f0853_christmas_tree_snowy',
          shader: 'shaders/f0853_christmas_tree_snowy_gpu.frag',
        );

  @override
  F0853ChristmasTreeSnowyMetadata get metadata => F0853ChristmasTreeSnowyMetadata.instance;

  @override
  List<F0853ChristmasTreeSnowyPreset> get presets => F0853ChristmasTreeSnowyPresets.all;

  @override
  List<F0853ChristmasTreeSnowyVariant> get variants => F0853ChristmasTreeSnowyVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
