// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0721_paul_bourke_hexagonal_random_tiling_presets.dart';
import 'f0721_paul_bourke_hexagonal_random_tiling_variants.dart';
import 'f0721_paul_bourke_hexagonal_random_tiling_metadata.dart';

/// Paul Bourke Hexagonal Random Tiling — Tiling & Aperiodic.
class F0721PaulBourkeHexagonalRandomTiling extends IFSModule {
  F0721PaulBourkeHexagonalRandomTiling()
      : super(
          id: 'f0721_paul_bourke_hexagonal_random_tiling',
          shader: 'shaders/f0721_paul_bourke_hexagonal_random_tiling_gpu.frag',
        );

  @override
  F0721PaulBourkeHexagonalRandomTilingMetadata get metadata => F0721PaulBourkeHexagonalRandomTilingMetadata.instance;

  @override
  List<F0721PaulBourkeHexagonalRandomTilingPreset> get presets => F0721PaulBourkeHexagonalRandomTilingPresets.all;

  @override
  List<F0721PaulBourkeHexagonalRandomTilingVariant> get variants => F0721PaulBourkeHexagonalRandomTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
