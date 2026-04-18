// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0704_truchet_tile_classic_presets.dart';
import 'f0704_truchet_tile_classic_variants.dart';
import 'f0704_truchet_tile_classic_metadata.dart';

/// Truchet Tile (Classic) — Tiling & Aperiodic.
class F0704TruchetTileClassic extends IFSModule {
  F0704TruchetTileClassic()
      : super(
          id: 'f0704_truchet_tile_classic',
          shader: 'shaders/f0704_truchet_tile_classic_gpu.frag',
        );

  @override
  F0704TruchetTileClassicMetadata get metadata => F0704TruchetTileClassicMetadata.instance;

  @override
  List<F0704TruchetTileClassicPreset> get presets => F0704TruchetTileClassicPresets.all;

  @override
  List<F0704TruchetTileClassicVariant> get variants => F0704TruchetTileClassicVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
