import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/rendering/fractal_report_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/actions/viewer_effects_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saves report through report service with sorted tags and visual state',
      () async {
    final dir = Directory.systemTemp.createTempSync('viewer_effects_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final effects = ViewerEffectsController(
      reportService: FractalReportService(issuesDirectory: dir.path),
    );

    final file = await effects.saveFractalReport(
      controller: controller,
      moduleName: 'Mandelbrot',
      shareUrl: 'https://example.test/view',
      tags: const ['No image', 'Bad Thumbnail'],
      notes: 'dark frame',
    );

    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(json['moduleId'], controller.module.id);
    expect(json['tags'], ['Bad Thumbnail', 'No image']);
    expect((json['visualState'] as Map)['kaleidoscopeEnabled'], isFalse);
  });
}
