// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0113_burning_ship_d_7_presets.dart';
import 'f0113_burning_ship_d_7_variants.dart';
import 'f0113_burning_ship_d_7_metadata.dart';

/// Burning Ship d=7 — Escape-Time (Complex Plane).
class F0113BurningShipD7 extends EscapeTimeModule {
  F0113BurningShipD7()
      : super(
          id: 'f0113_burning_ship_d_7',
          shader: 'shaders/f0113_burning_ship_d_7_gpu.frag',
        );

  @override
  F0113BurningShipD7Metadata get metadata => F0113BurningShipD7Metadata.instance;

  @override
  List<F0113BurningShipD7Preset> get presets => F0113BurningShipD7Presets.all;

  @override
  List<F0113BurningShipD7Variant> get variants => F0113BurningShipD7Variants.all;

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
