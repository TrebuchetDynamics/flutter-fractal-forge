// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0256_moore_like_hilbert_presets.dart';
import 'f0256_moore_like_hilbert_variants.dart';
import 'f0256_moore_like_hilbert_metadata.dart';

/// Moore-like Hilbert — L-Systems & Space-Filling.
class F0256MooreLikeHilbert extends LSystemModule {
  F0256MooreLikeHilbert()
      : super(
          id: 'f0256_moore_like_hilbert',
          shader: 'shaders/f0256_moore_like_hilbert_gpu.frag',
        );

  @override
  F0256MooreLikeHilbertMetadata get metadata => F0256MooreLikeHilbertMetadata.instance;

  @override
  List<F0256MooreLikeHilbertPreset> get presets => F0256MooreLikeHilbertPresets.all;

  @override
  List<F0256MooreLikeHilbertVariant> get variants => F0256MooreLikeHilbertVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
