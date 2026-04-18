// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0717_stampfli_dodecagonal_presets.dart';
import 'f0717_stampfli_dodecagonal_variants.dart';
import 'f0717_stampfli_dodecagonal_metadata.dart';

/// Stampfli Dodecagonal — Tiling & Aperiodic.
class F0717StampfliDodecagonal extends IFSModule {
  F0717StampfliDodecagonal()
      : super(
          id: 'f0717_stampfli_dodecagonal',
          shader: 'shaders/f0717_stampfli_dodecagonal_gpu.frag',
        );

  @override
  F0717StampfliDodecagonalMetadata get metadata => F0717StampfliDodecagonalMetadata.instance;

  @override
  List<F0717StampfliDodecagonalPreset> get presets => F0717StampfliDodecagonalPresets.all;

  @override
  List<F0717StampfliDodecagonalVariant> get variants => F0717StampfliDodecagonalVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
