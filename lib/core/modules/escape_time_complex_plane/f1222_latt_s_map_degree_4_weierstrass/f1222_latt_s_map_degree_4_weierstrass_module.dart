// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1222_latt_s_map_degree_4_weierstrass_presets.dart';
import 'f1222_latt_s_map_degree_4_weierstrass_variants.dart';
import 'f1222_latt_s_map_degree_4_weierstrass_metadata.dart';

/// Lattès Map (degree 4, Weierstrass) — Escape-Time (Complex Plane).
class F1222LattSMapDegree4Weierstrass extends EscapeTimeModule {
  F1222LattSMapDegree4Weierstrass()
      : super(
          id: 'f1222_latt_s_map_degree_4_weierstrass',
          shader: 'shaders/f1222_latt_s_map_degree_4_weierstrass_gpu.frag',
        );

  @override
  F1222LattSMapDegree4WeierstrassMetadata get metadata => F1222LattSMapDegree4WeierstrassMetadata.instance;

  @override
  List<F1222LattSMapDegree4WeierstrassPreset> get presets => F1222LattSMapDegree4WeierstrassPresets.all;

  @override
  List<F1222LattSMapDegree4WeierstrassVariant> get variants => F1222LattSMapDegree4WeierstrassVariants.all;

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
