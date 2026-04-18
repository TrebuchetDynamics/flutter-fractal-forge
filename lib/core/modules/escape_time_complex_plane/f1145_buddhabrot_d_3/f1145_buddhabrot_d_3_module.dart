// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1145_buddhabrot_d_3_presets.dart';
import 'f1145_buddhabrot_d_3_variants.dart';
import 'f1145_buddhabrot_d_3_metadata.dart';

/// Buddhabrot d=3 — Escape-Time (Complex Plane).
class F1145BuddhabrotD3 extends EscapeTimeModule {
  F1145BuddhabrotD3()
      : super(
          id: 'f1145_buddhabrot_d_3',
          shader: 'shaders/f1145_buddhabrot_d_3_gpu.frag',
        );

  @override
  F1145BuddhabrotD3Metadata get metadata => F1145BuddhabrotD3Metadata.instance;

  @override
  List<F1145BuddhabrotD3Preset> get presets => F1145BuddhabrotD3Presets.all;

  @override
  List<F1145BuddhabrotD3Variant> get variants => F1145BuddhabrotD3Variants.all;

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
