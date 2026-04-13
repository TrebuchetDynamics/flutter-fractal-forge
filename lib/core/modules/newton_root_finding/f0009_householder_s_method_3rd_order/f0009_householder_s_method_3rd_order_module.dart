// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0009_householder_s_method_3rd_order_presets.dart';
import 'f0009_householder_s_method_3rd_order_variants.dart';
import 'f0009_householder_s_method_3rd_order_metadata.dart';

/// Householder's Method (3rd Order) — Newton / Root-Finding.
class F0009HouseholderSMethod3rdOrder extends EscapeTimeModule {
  F0009HouseholderSMethod3rdOrder()
      : super(
          id: 'f0009_householder_s_method_3rd_order',
          shader: 'shaders/f0009_householder_s_method_3rd_order_gpu.frag',
        );

  @override
  F0009HouseholderSMethod3rdOrderMetadata get metadata => F0009HouseholderSMethod3rdOrderMetadata.instance;

  @override
  List<F0009HouseholderSMethod3rdOrderPreset> get presets => F0009HouseholderSMethod3rdOrderPresets.all;

  @override
  List<F0009HouseholderSMethod3rdOrderVariant> get variants => F0009HouseholderSMethod3rdOrderVariants.all;

  @override
  double get defaultPower => 3.0;

  @override
  double get defaultBailout => 0.001;

  @override
  int get defaultIterations => 48;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
