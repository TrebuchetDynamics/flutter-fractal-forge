// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0698_sphinx_tiling_presets.dart';
import 'f0698_sphinx_tiling_variants.dart';
import 'f0698_sphinx_tiling_metadata.dart';

/// Sphinx Tiling — Tiling & Aperiodic.
class F0698SphinxTiling extends IFSModule {
  F0698SphinxTiling()
      : super(
          id: 'f0698_sphinx_tiling',
          shader: 'shaders/f0698_sphinx_tiling_gpu.frag',
        );

  @override
  F0698SphinxTilingMetadata get metadata => F0698SphinxTilingMetadata.instance;

  @override
  List<F0698SphinxTilingPreset> get presets => F0698SphinxTilingPresets.all;

  @override
  List<F0698SphinxTilingVariant> get variants => F0698SphinxTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
