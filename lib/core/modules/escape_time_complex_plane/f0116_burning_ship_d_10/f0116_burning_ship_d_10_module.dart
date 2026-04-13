// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0116_burning_ship_d_10_presets.dart';
import 'f0116_burning_ship_d_10_variants.dart';
import 'f0116_burning_ship_d_10_metadata.dart';

/// Burning Ship d=10 — Escape-Time (Complex Plane).
class F0116BurningShipD10 extends EscapeTimeModule {
  F0116BurningShipD10()
      : super(
          id: 'f0116_burning_ship_d_10',
          shader: 'shaders/f0116_burning_ship_d_10_gpu.frag',
        );

  @override
  F0116BurningShipD10Metadata get metadata => F0116BurningShipD10Metadata.instance;

  @override
  List<F0116BurningShipD10Preset> get presets => F0116BurningShipD10Presets.all;

  @override
  List<F0116BurningShipD10Variant> get variants => F0116BurningShipD10Variants.all;

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
