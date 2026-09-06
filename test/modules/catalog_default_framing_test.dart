import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import '../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('audited power-family presets show their boundary', () async {
    final registry = ModuleRegistry();
    for (final id in ['multibrot5', 'multijulia9', 'tricorn_power7_julia']) {
      final module = registry.byId(id);
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
      for (final preset in [module.defaultPreset, ...module.builtInPresets]) {
        final params = {...module.defaultPreset.params, ...preset.params};
        final bytes = await renderTestShaderFrame(
            program: program,
            shaderAsset: module.shaderAsset,
            width: 96,
            height: 96,
            uniforms: [
              0,
              96,
              96,
              preset.view.pan.x,
              preset.view.pan.y,
              preset.view.zoom,
              (params['iterations']! as num).toDouble(),
              (params['bailout']! as num).toDouble(),
              (params['colorScheme']! as num).toDouble(),
              0
            ]);
        final image = img.Image.fromBytes(
            width: 96, height: 96, bytes: bytes.buffer, numChannels: 4);
        final metrics = RenderAuditMetrics.fromImage(image);
        expect(metrics.verdict, 'pass', reason: '$id ${preset.id}');
        expect(metrics.nonBlackPixelRatio, greaterThan(.15),
            reason: '$id ${preset.id}');
        expect(metrics.blackPixelRatio, greaterThan(.05),
            reason: '$id ${preset.id}');
      }
    }
  });
}
