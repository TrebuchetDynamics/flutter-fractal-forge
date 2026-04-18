// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0845_murray_polygon_curve_order_5_presets.dart';
import 'f0845_murray_polygon_curve_order_5_variants.dart';
import 'f0845_murray_polygon_curve_order_5_metadata.dart';

/// Murray Polygon Curve (Order 5) — L-Systems & Space-Filling.
class F0845MurrayPolygonCurveOrder5 extends LSystemModule {
  F0845MurrayPolygonCurveOrder5()
      : super(
          id: 'f0845_murray_polygon_curve_order_5',
          shader: 'shaders/f0845_murray_polygon_curve_order_5_gpu.frag',
        );

  @override
  F0845MurrayPolygonCurveOrder5Metadata get metadata => F0845MurrayPolygonCurveOrder5Metadata.instance;

  @override
  List<F0845MurrayPolygonCurveOrder5Preset> get presets => F0845MurrayPolygonCurveOrder5Presets.all;

  @override
  List<F0845MurrayPolygonCurveOrder5Variant> get variants => F0845MurrayPolygonCurveOrder5Variants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
