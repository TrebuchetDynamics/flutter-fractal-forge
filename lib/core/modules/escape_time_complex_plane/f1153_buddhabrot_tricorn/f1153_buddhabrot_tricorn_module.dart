// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1153_buddhabrot_tricorn_presets.dart';
import 'f1153_buddhabrot_tricorn_variants.dart';
import 'f1153_buddhabrot_tricorn_metadata.dart';

/// Buddhabrot Tricorn — Escape-Time (Complex Plane).
class F1153BuddhabrotTricorn extends EscapeTimeModule {
  F1153BuddhabrotTricorn()
      : super(
          id: 'f1153_buddhabrot_tricorn',
          shader: 'shaders/f1153_buddhabrot_tricorn_gpu.frag',
        );

  @override
  F1153BuddhabrotTricornMetadata get metadata => F1153BuddhabrotTricornMetadata.instance;

  @override
  List<F1153BuddhabrotTricornPreset> get presets => F1153BuddhabrotTricornPresets.all;

  @override
  List<F1153BuddhabrotTricornVariant> get variants => F1153BuddhabrotTricornVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1024;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
