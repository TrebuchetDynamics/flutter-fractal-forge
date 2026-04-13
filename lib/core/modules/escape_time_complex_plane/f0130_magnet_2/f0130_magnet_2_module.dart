// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0130_magnet_2_presets.dart';
import 'f0130_magnet_2_variants.dart';
import 'f0130_magnet_2_metadata.dart';

/// Magnet 2 — Escape-Time (Complex Plane).
class F0130Magnet2 extends EscapeTimeModule {
  F0130Magnet2()
      : super(
          id: 'f0130_magnet_2',
          shader: 'shaders/f0130_magnet_2_gpu.frag',
        );

  @override
  F0130Magnet2Metadata get metadata => F0130Magnet2Metadata.instance;

  @override
  List<F0130Magnet2Preset> get presets => F0130Magnet2Presets.all;

  @override
  List<F0130Magnet2Variant> get variants => F0130Magnet2Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
