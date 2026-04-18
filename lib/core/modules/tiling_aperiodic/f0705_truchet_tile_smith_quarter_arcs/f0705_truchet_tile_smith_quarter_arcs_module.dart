// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0705_truchet_tile_smith_quarter_arcs_presets.dart';
import 'f0705_truchet_tile_smith_quarter_arcs_variants.dart';
import 'f0705_truchet_tile_smith_quarter_arcs_metadata.dart';

/// Truchet Tile (Smith Quarter-Arcs) — Tiling & Aperiodic.
class F0705TruchetTileSmithQuarterArcs extends IFSModule {
  F0705TruchetTileSmithQuarterArcs()
      : super(
          id: 'f0705_truchet_tile_smith_quarter_arcs',
          shader: 'shaders/f0705_truchet_tile_smith_quarter_arcs_gpu.frag',
        );

  @override
  F0705TruchetTileSmithQuarterArcsMetadata get metadata => F0705TruchetTileSmithQuarterArcsMetadata.instance;

  @override
  List<F0705TruchetTileSmithQuarterArcsPreset> get presets => F0705TruchetTileSmithQuarterArcsPresets.all;

  @override
  List<F0705TruchetTileSmithQuarterArcsVariant> get variants => F0705TruchetTileSmithQuarterArcsVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
