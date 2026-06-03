import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/features/export/custom_export_dimensions.dart';
import 'package:flutter_fractals/features/export/export_resolution_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveCustomExportDimension', () {
    test('uses positive field text before current value or fallback', () {
      expect(
        resolveCustomExportDimension(
          fieldText: '2048',
          currentValue: 1024,
          fallback: defaultCustomExportWidth,
        ),
        2048,
      );
    });

    test('falls back to current value when field text is invalid', () {
      expect(
        resolveCustomExportDimension(
          fieldText: 'not a number',
          currentValue: 1024,
          fallback: defaultCustomExportWidth,
        ),
        1024,
      );
    });

    test('normalizes oversized field text through export dimension policy', () {
      expect(
        resolveCustomExportDimension(
          fieldText: '${1 << 40}',
          currentValue: null,
          fallback: defaultCustomExportWidth,
        ),
        ExportDimensionPolicy.maxPixelDimension,
      );
    });

    test('normalizes oversized current value fallback through policy', () {
      expect(
        resolveCustomExportDimension(
          fieldText: '',
          currentValue: 1 << 40,
          fallback: defaultCustomExportWidth,
        ),
        ExportDimensionPolicy.maxPixelDimension,
      );
    });
  });

  group('resolveCustomExportDimensionPlan', () {
    test('exposes winning source and clamp provenance', () {
      final clampedField = resolveCustomExportDimensionPlan(
        fieldText: '${1 << 40}',
        currentValue: 1024,
        fallback: defaultCustomExportWidth,
      );
      final currentFallback = resolveCustomExportDimensionPlan(
        fieldText: '0',
        currentValue: 1024,
        fallback: defaultCustomExportWidth,
      );

      expect(clampedField.value, ExportDimensionPolicy.maxPixelDimension);
      expect(clampedField.source, CustomExportDimensionSource.fieldText);
      expect(clampedField.wasClamped, isTrue);
      expect(currentFallback.value, 1024);
      expect(currentFallback.source, CustomExportDimensionSource.currentValue);
      expect(currentFallback.wasClamped, isFalse);
    });
  });

  group('withResolvedCustomExportDimensions', () {
    test('stores normalized custom dimensions in the export payload', () {
      final resolved = withResolvedCustomExportDimensions(
        options: const ExportOptions(
          resolution: ExportResolution.custom,
          customWidth: 1 << 40,
          customHeight: 720,
        ),
        widthText: '',
        heightText: '${1 << 35}',
      );

      expect(resolved.customWidth, ExportDimensionPolicy.maxPixelDimension);
      expect(resolved.customHeight, ExportDimensionPolicy.maxPixelDimension);
    });
  });

  group('ExportResolutionSummary', () {
    test('uses oriented target dimensions for portrait preset summaries', () {
      final summary = ExportResolutionSummary.fromEffectiveOptions(
        options: const ExportOptions(resolution: ExportResolution.fullHd),
        screenWidth: 800,
        screenHeight: 1200,
      );

      expect(summary.usesScreenResolution, isFalse);
      expect(summary.label(screenResolutionLabel: 'Screen'), '1080×1920');
    });

    test('preserves screen-resolution summary copy', () {
      final summary = ExportResolutionSummary.fromEffectiveOptions(
        options: const ExportOptions(resolution: ExportResolution.screen),
        screenWidth: 800,
        screenHeight: 1200,
      );

      expect(summary.usesScreenResolution, isTrue);
      expect(summary.label(screenResolutionLabel: 'Screen'), 'Screen');
    });
  });
}
