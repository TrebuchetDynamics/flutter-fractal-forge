// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1146_buddhabrot_d_4_presets.dart';
import 'f1146_buddhabrot_d_4_variants.dart';
import 'f1146_buddhabrot_d_4_metadata.dart';

/// Buddhabrot d=4 — Escape-Time (Complex Plane).
class F1146BuddhabrotD4 extends EscapeTimeModule {
  F1146BuddhabrotD4()
      : super(
          id: 'f1146_buddhabrot_d_4',
          shader: 'shaders/f1146_buddhabrot_d_4_gpu.frag',
        );

  @override
  F1146BuddhabrotD4Metadata get metadata => F1146BuddhabrotD4Metadata.instance;

  @override
  List<F1146BuddhabrotD4Preset> get presets => F1146BuddhabrotD4Presets.all;

  @override
  List<F1146BuddhabrotD4Variant> get variants => F1146BuddhabrotD4Variants.all;

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
