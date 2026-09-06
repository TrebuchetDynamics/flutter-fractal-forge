import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/features/renderer/diagnostics/render_audit_metrics.dart';
import 'package:flutter_fractals/core/modules/builders/shared_catalogs/shared_escape_power_catalog.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/render_test_shader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('high-power Tricorn defaults frame both the set and its exterior',
      () async {
    final registry = ModuleRegistry();
    final entries = sharedEscapePowerCatalogEntries.where(
        (e) => e.family == SharedEscapePowerFamily.tricorn && e.power >= 9);
    for (final entry in entries) {
      final module = registry.byId(entry.id);
      final preset = module.defaultPreset;
      final program = await ui.FragmentProgram.fromAsset(module.shaderAsset);
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
            (preset.params['iterations']! as num).toDouble(),
            (preset.params['bailout']! as num).toDouble(),
            0,
            0,
            entry.power
          ]);
      final image = img.Image.fromBytes(
          width: 96, height: 96, bytes: bytes.buffer, numChannels: 4);
      final metrics = RenderAuditMetrics.fromImage(image);
      expect(metrics.verdict, 'pass', reason: entry.id);
      expect(metrics.nonBlackPixelRatio, greaterThan(.15), reason: entry.id);
      expect(metrics.blackPixelRatio, greaterThan(.05), reason: entry.id);
    }
  });

  test('registers reviewed Tricorn and Burning Ship power identities', () {
    final registry = ModuleRegistry();
    final modulesById = {
      for (final module in registry.modules) module.id: module
    };

    expect(sharedEscapePowerCatalogEntries, hasLength(17));
    for (final entry in sharedEscapePowerCatalogEntries) {
      final module = modulesById[entry.id];
      expect(module, isNotNull, reason: entry.id);
      expect(module!.defaultPreset.moduleId, entry.id);
      expect(module.defaultPreset.params['power'], entry.power);
      expect(module.parameters.any((p) => p.id == 'power'), isTrue);
    }
  });

  test('keeps generic Tricorn and Burning Ship configured with power uniform',
      () {
    final registry = ModuleRegistry();

    expect(registry.byId('tricorn').defaultPreset.params['power'], 2.0);
    expect(registry.byId('burning_ship').defaultPreset.params['power'], 2.0);
  });
}
