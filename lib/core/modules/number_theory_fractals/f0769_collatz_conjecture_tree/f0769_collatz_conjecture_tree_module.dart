// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0769_collatz_conjecture_tree_presets.dart';
import 'f0769_collatz_conjecture_tree_variants.dart';
import 'f0769_collatz_conjecture_tree_metadata.dart';

/// Collatz Conjecture Tree — Number-Theory Fractals.
class F0769CollatzConjectureTree extends CellularModule {
  F0769CollatzConjectureTree()
      : super(
          id: 'f0769_collatz_conjecture_tree',
          shader: 'shaders/f0769_collatz_conjecture_tree_gpu.frag',
        );

  @override
  F0769CollatzConjectureTreeMetadata get metadata => F0769CollatzConjectureTreeMetadata.instance;

  @override
  List<F0769CollatzConjectureTreePreset> get presets => F0769CollatzConjectureTreePresets.all;

  @override
  List<F0769CollatzConjectureTreeVariant> get variants => F0769CollatzConjectureTreeVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
