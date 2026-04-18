// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1070_tyler_rose_presets.dart';
import 'f1070_tyler_rose_variants.dart';
import 'f1070_tyler_rose_metadata.dart';

/// Tyler Rose — Strange Attractors.
class F1070TylerRose extends AttractorModule {
  F1070TylerRose()
      : super(
          id: 'f1070_tyler_rose',
          shader: 'shaders/f1070_tyler_rose_gpu.frag',
        );

  @override
  F1070TylerRoseMetadata get metadata => F1070TylerRoseMetadata.instance;

  @override
  List<F1070TylerRosePreset> get presets => F1070TylerRosePresets.all;

  @override
  List<F1070TylerRoseVariant> get variants => F1070TylerRoseVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
