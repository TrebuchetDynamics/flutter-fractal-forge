// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0844_murray_polygon_curve_order_3_presets.dart';
import 'f0844_murray_polygon_curve_order_3_variants.dart';
import 'f0844_murray_polygon_curve_order_3_metadata.dart';

/// Murray Polygon Curve (Order 3) — L-Systems & Space-Filling.
class F0844MurrayPolygonCurveOrder3 extends LSystemModule {
  F0844MurrayPolygonCurveOrder3()
      : super(
          id: 'f0844_murray_polygon_curve_order_3',
          shader: 'shaders/f0844_murray_polygon_curve_order_3_gpu.frag',
        );

  @override
  F0844MurrayPolygonCurveOrder3Metadata get metadata => F0844MurrayPolygonCurveOrder3Metadata.instance;

  @override
  List<F0844MurrayPolygonCurveOrder3Preset> get presets => F0844MurrayPolygonCurveOrder3Presets.all;

  @override
  List<F0844MurrayPolygonCurveOrder3Variant> get variants => F0844MurrayPolygonCurveOrder3Variants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
