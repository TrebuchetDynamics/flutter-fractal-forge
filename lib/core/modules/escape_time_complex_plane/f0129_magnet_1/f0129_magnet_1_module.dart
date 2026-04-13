// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0129_magnet_1_presets.dart';
import 'f0129_magnet_1_variants.dart';
import 'f0129_magnet_1_metadata.dart';

/// Magnet 1 — Escape-Time (Complex Plane).
class F0129Magnet1 extends EscapeTimeModule {
  F0129Magnet1()
      : super(
          id: 'f0129_magnet_1',
          shader: 'shaders/f0129_magnet_1_gpu.frag',
        );

  @override
  F0129Magnet1Metadata get metadata => F0129Magnet1Metadata.instance;

  @override
  List<F0129Magnet1Preset> get presets => F0129Magnet1Presets.all;

  @override
  List<F0129Magnet1Variant> get variants => F0129Magnet1Variants.all;

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
