// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0706_truchet_tile_extended_multi_arc_presets.dart';
import 'f0706_truchet_tile_extended_multi_arc_variants.dart';
import 'f0706_truchet_tile_extended_multi_arc_metadata.dart';

/// Truchet Tile (Extended Multi-Arc) — Tiling & Aperiodic.
class F0706TruchetTileExtendedMultiArc extends IFSModule {
  F0706TruchetTileExtendedMultiArc()
      : super(
          id: 'f0706_truchet_tile_extended_multi_arc',
          shader: 'shaders/f0706_truchet_tile_extended_multi_arc_gpu.frag',
        );

  @override
  F0706TruchetTileExtendedMultiArcMetadata get metadata => F0706TruchetTileExtendedMultiArcMetadata.instance;

  @override
  List<F0706TruchetTileExtendedMultiArcPreset> get presets => F0706TruchetTileExtendedMultiArcPresets.all;

  @override
  List<F0706TruchetTileExtendedMultiArcVariant> get variants => F0706TruchetTileExtendedMultiArcVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
