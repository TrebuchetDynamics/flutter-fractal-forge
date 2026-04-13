// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0254_pentaplexity_presets.dart';
import 'f0254_pentaplexity_variants.dart';
import 'f0254_pentaplexity_metadata.dart';

/// Pentaplexity — L-Systems & Space-Filling.
class F0254Pentaplexity extends LSystemModule {
  F0254Pentaplexity()
      : super(
          id: 'f0254_pentaplexity',
          shader: 'shaders/f0254_pentaplexity_gpu.frag',
        );

  @override
  F0254PentaplexityMetadata get metadata => F0254PentaplexityMetadata.instance;

  @override
  List<F0254PentaplexityPreset> get presets => F0254PentaplexityPresets.all;

  @override
  List<F0254PentaplexityVariant> get variants => F0254PentaplexityVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
