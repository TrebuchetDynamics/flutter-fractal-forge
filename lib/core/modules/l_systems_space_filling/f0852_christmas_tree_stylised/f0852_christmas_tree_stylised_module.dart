// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0852_christmas_tree_stylised_presets.dart';
import 'f0852_christmas_tree_stylised_variants.dart';
import 'f0852_christmas_tree_stylised_metadata.dart';

/// Christmas Tree Stylised — L-Systems & Space-Filling.
class F0852ChristmasTreeStylised extends LSystemModule {
  F0852ChristmasTreeStylised()
      : super(
          id: 'f0852_christmas_tree_stylised',
          shader: 'shaders/f0852_christmas_tree_stylised_gpu.frag',
        );

  @override
  F0852ChristmasTreeStylisedMetadata get metadata => F0852ChristmasTreeStylisedMetadata.instance;

  @override
  List<F0852ChristmasTreeStylisedPreset> get presets => F0852ChristmasTreeStylisedPresets.all;

  @override
  List<F0852ChristmasTreeStylisedVariant> get variants => F0852ChristmasTreeStylisedVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
