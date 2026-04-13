// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0255_hexagonal_gosper_presets.dart';
import 'f0255_hexagonal_gosper_variants.dart';
import 'f0255_hexagonal_gosper_metadata.dart';

/// Hexagonal Gosper — L-Systems & Space-Filling.
class F0255HexagonalGosper extends LSystemModule {
  F0255HexagonalGosper()
      : super(
          id: 'f0255_hexagonal_gosper',
          shader: 'shaders/f0255_hexagonal_gosper_gpu.frag',
        );

  @override
  F0255HexagonalGosperMetadata get metadata => F0255HexagonalGosperMetadata.instance;

  @override
  List<F0255HexagonalGosperPreset> get presets => F0255HexagonalGosperPresets.all;

  @override
  List<F0255HexagonalGosperVariant> get variants => F0255HexagonalGosperVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
