// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1223_latt_s_map_degree_9_presets.dart';
import 'f1223_latt_s_map_degree_9_variants.dart';
import 'f1223_latt_s_map_degree_9_metadata.dart';

/// Lattès Map (degree 9) — Escape-Time (Complex Plane).
class F1223LattSMapDegree9 extends EscapeTimeModule {
  F1223LattSMapDegree9()
      : super(
          id: 'f1223_latt_s_map_degree_9',
          shader: 'shaders/f1223_latt_s_map_degree_9_gpu.frag',
        );

  @override
  F1223LattSMapDegree9Metadata get metadata => F1223LattSMapDegree9Metadata.instance;

  @override
  List<F1223LattSMapDegree9Preset> get presets => F1223LattSMapDegree9Presets.all;

  @override
  List<F1223LattSMapDegree9Variant> get variants => F1223LattSMapDegree9Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
