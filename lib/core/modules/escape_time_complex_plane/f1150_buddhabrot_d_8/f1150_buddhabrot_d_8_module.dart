// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1150_buddhabrot_d_8_presets.dart';
import 'f1150_buddhabrot_d_8_variants.dart';
import 'f1150_buddhabrot_d_8_metadata.dart';

/// Buddhabrot d=8 — Escape-Time (Complex Plane).
class F1150BuddhabrotD8 extends EscapeTimeModule {
  F1150BuddhabrotD8()
      : super(
          id: 'f1150_buddhabrot_d_8',
          shader: 'shaders/f1150_buddhabrot_d_8_gpu.frag',
        );

  @override
  F1150BuddhabrotD8Metadata get metadata => F1150BuddhabrotD8Metadata.instance;

  @override
  List<F1150BuddhabrotD8Preset> get presets => F1150BuddhabrotD8Presets.all;

  @override
  List<F1150BuddhabrotD8Variant> get variants => F1150BuddhabrotD8Variants.all;

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
