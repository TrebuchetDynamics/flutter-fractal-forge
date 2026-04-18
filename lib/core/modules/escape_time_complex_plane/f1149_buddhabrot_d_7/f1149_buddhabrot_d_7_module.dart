// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1149_buddhabrot_d_7_presets.dart';
import 'f1149_buddhabrot_d_7_variants.dart';
import 'f1149_buddhabrot_d_7_metadata.dart';

/// Buddhabrot d=7 — Escape-Time (Complex Plane).
class F1149BuddhabrotD7 extends EscapeTimeModule {
  F1149BuddhabrotD7()
      : super(
          id: 'f1149_buddhabrot_d_7',
          shader: 'shaders/f1149_buddhabrot_d_7_gpu.frag',
        );

  @override
  F1149BuddhabrotD7Metadata get metadata => F1149BuddhabrotD7Metadata.instance;

  @override
  List<F1149BuddhabrotD7Preset> get presets => F1149BuddhabrotD7Presets.all;

  @override
  List<F1149BuddhabrotD7Variant> get variants => F1149BuddhabrotD7Variants.all;

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
