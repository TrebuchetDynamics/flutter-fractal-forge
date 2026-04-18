// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1147_buddhabrot_d_5_presets.dart';
import 'f1147_buddhabrot_d_5_variants.dart';
import 'f1147_buddhabrot_d_5_metadata.dart';

/// Buddhabrot d=5 — Escape-Time (Complex Plane).
class F1147BuddhabrotD5 extends EscapeTimeModule {
  F1147BuddhabrotD5()
      : super(
          id: 'f1147_buddhabrot_d_5',
          shader: 'shaders/f1147_buddhabrot_d_5_gpu.frag',
        );

  @override
  F1147BuddhabrotD5Metadata get metadata => F1147BuddhabrotD5Metadata.instance;

  @override
  List<F1147BuddhabrotD5Preset> get presets => F1147BuddhabrotD5Presets.all;

  @override
  List<F1147BuddhabrotD5Variant> get variants => F1147BuddhabrotD5Variants.all;

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
