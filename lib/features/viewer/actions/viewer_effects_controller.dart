import 'dart:io';

import 'package:flutter_fractals/core/services/rendering/fractal_report_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';

class ViewerEffectsController {
  static const defaultReportTags = FractalReportService.defaultTags;

  final FractalReportService _reportService;

  ViewerEffectsController({FractalReportService? reportService})
      : _reportService = reportService ?? const FractalReportService();

  Future<File> saveFractalReport({
    required FractalController controller,
    required String moduleName,
    required String shareUrl,
    required List<String> tags,
    String notes = '',
  }) {
    return _reportService.save(
      moduleId: controller.module.id,
      moduleName: moduleName,
      tags: List<String>.from(tags)..sort(),
      params: controller.params,
      view: controller.view,
      shareUrl: shareUrl,
      notes: notes,
      visualState: _reportVisualState(controller),
    );
  }

  String buildFractalReportJson({
    required FractalController controller,
    required String moduleName,
    required String shareUrl,
    required List<String> tags,
    String notes = '',
  }) {
    return _reportService.buildJson(
      moduleId: controller.module.id,
      moduleName: moduleName,
      tags: List<String>.from(tags)..sort(),
      params: controller.params,
      view: controller.view,
      shareUrl: shareUrl,
      notes: notes,
      visualState: _reportVisualState(controller),
    );
  }

  Map<String, Object?> _reportVisualState(FractalController controller) => {
        'transparentBackground': controller.transparentBackground,
        'rotationLocked': controller.rotationLocked,
        'glowEnabled': controller.glowEnabled,
        'glowSigma': controller.glowSigma,
        'glowIntensity': controller.glowIntensity,
        'kaleidoscopeEnabled': controller.kaleidoscopeEnabled,
        'kaleidoscopeSectors': controller.kaleidoscopeSectors,
        'kaleidoscopeMirror': controller.kaleidoscopeMirror,
        'kaleidoscopeRotation': controller.kaleidoscopeRotation,
        'kaleidoscopeMirrorMode': controller.kaleidoscopeMirrorMode,
      };
}
