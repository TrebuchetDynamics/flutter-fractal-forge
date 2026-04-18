// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0700_rep_4_l_tile_presets.dart';
import 'f0700_rep_4_l_tile_variants.dart';
import 'f0700_rep_4_l_tile_metadata.dart';

/// Rep-4 L-Tile — Tiling & Aperiodic.
class F0700Rep4LTile extends IFSModule {
  F0700Rep4LTile()
      : super(
          id: 'f0700_rep_4_l_tile',
          shader: 'shaders/f0700_rep_4_l_tile_gpu.frag',
        );

  @override
  F0700Rep4LTileMetadata get metadata => F0700Rep4LTileMetadata.instance;

  @override
  List<F0700Rep4LTilePreset> get presets => F0700Rep4LTilePresets.all;

  @override
  List<F0700Rep4LTileVariant> get variants => F0700Rep4LTileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
