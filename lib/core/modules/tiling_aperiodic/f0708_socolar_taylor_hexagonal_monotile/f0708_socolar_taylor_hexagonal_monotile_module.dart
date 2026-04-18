// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0708_socolar_taylor_hexagonal_monotile_presets.dart';
import 'f0708_socolar_taylor_hexagonal_monotile_variants.dart';
import 'f0708_socolar_taylor_hexagonal_monotile_metadata.dart';

/// Socolar-Taylor Hexagonal Monotile — Tiling & Aperiodic.
class F0708SocolarTaylorHexagonalMonotile extends IFSModule {
  F0708SocolarTaylorHexagonalMonotile()
      : super(
          id: 'f0708_socolar_taylor_hexagonal_monotile',
          shader: 'shaders/f0708_socolar_taylor_hexagonal_monotile_gpu.frag',
        );

  @override
  F0708SocolarTaylorHexagonalMonotileMetadata get metadata => F0708SocolarTaylorHexagonalMonotileMetadata.instance;

  @override
  List<F0708SocolarTaylorHexagonalMonotilePreset> get presets => F0708SocolarTaylorHexagonalMonotilePresets.all;

  @override
  List<F0708SocolarTaylorHexagonalMonotileVariant> get variants => F0708SocolarTaylorHexagonalMonotileVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
