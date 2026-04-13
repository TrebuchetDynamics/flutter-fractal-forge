// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0401_icon_rosette_d4_presets.dart';
import 'f0401_icon_rosette_d4_variants.dart';
import 'f0401_icon_rosette_d4_metadata.dart';

/// Icon — Rosette D4 — Strange Attractors.
class F0401IconRosetteD4 extends AttractorModule {
  F0401IconRosetteD4()
      : super(
          id: 'f0401_icon_rosette_d4',
          shader: 'shaders/f0401_icon_rosette_d4_gpu.frag',
        );

  @override
  F0401IconRosetteD4Metadata get metadata => F0401IconRosetteD4Metadata.instance;

  @override
  List<F0401IconRosetteD4Preset> get presets => F0401IconRosetteD4Presets.all;

  @override
  List<F0401IconRosetteD4Variant> get variants => F0401IconRosetteD4Variants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
